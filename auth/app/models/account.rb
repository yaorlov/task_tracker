# frozen_string_literal: true

class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    admin: 'admin',
    manager: 'manager',
    finance: 'finance',
    worker: 'worker'
  }

  after_create do
    # ----------------------------- produce event -----------------------
    producer = WaterDrop::Producer.new do |config|
      config.deliver = true
      config.kafka = {
        'bootstrap.servers': ENV.fetch('KAFKA_URL'),
        'request.required.acks': 1
      }
    end

    event = {
      event_name: 'AccountsCreated',
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.now.to_s,
      producer: 'auth_service',
      data: self.reload.attributes.slice('public_id', 'email', 'role', 'full_name')
    }

    result = SchemaRegistry.validate_event(event, 'accounts.created', version: 1)

    if result.success?
      producer.produce_sync(payload: event.to_json, topic: 'accounts-stream')
    else
      logger.error('Invalid payload for "accounts-stream" event: ' + result.failure.join('; '))
      # store events in DB or produce invalid event to "invalid-events-topic"
    end

    producer.close
    # --------------------------------------------------------------------
  end
end
