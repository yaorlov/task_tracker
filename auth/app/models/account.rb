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
    producer = WaterDrop::Producer.new do |config|
      config.deliver = true
      config.kafka = {
        'bootstrap.servers': 'localhost:9092',
        'request.required.acks': 1
      }
    end

    event = {
      event_name: 'AccountCreated',
      data: self.reload.attributes.slice('public_id', 'email', 'role', 'full_name')
    }

    producer.produce_sync(payload: event.to_json, topic: 'accounts-stream')

    producer.close
  end
end
