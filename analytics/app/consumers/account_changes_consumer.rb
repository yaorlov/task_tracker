# frozen_string_literal: true

# AccountChangesConsumer consumes all events from the "accounts" and "accounts-stream" topics and
# stores Kafka events in the events table
class AccountChangesConsumer < ApplicationConsumer
  def consume
    params_batch.each do |message|
      puts '-' * 80
      p message
      puts '-' * 80

      case [message.payload['event_name'], message.payload['event_version']]
      when ['AccountsCreated', 1]
        result = SchemaRegistry.validate_event(message.payload, 'accounts.created', version: 1)

        if result.success?
          Rails.logger.info('AccountsCreated')
          ActiveRecord::Base.transaction do
            save_event!(message)
            Account.create!(message.payload['data'])
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['AccountsUpdated', 1]
        result = SchemaRegistry.validate_event(message.payload, 'accounts.updated', version: 1)

        if result.success?
          Rails.logger.info('AccountsUpdated')
          ActiveRecord::Base.transaction do
            save_event!(message)
            account(message).update!(full_name: message.payload['data']['full_name']) if account
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['AccountsDeleted', 1]
        result = SchemaRegistry.validate_event(message.payload, 'accounts.deleted', version: 1)

        if result.success?
          Rails.logger.info('AccountsDeleted')
          ActiveRecord::Base.transaction do
            save_event!(message)
            account(message).destroy! if account
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['AccountsRoleChanged', 1]
        result = SchemaRegistry.validate_event(message.payload, 'accounts.role_changed', version: 1)

        if result.success?
          Rails.logger.info('AccountsRoleChanged')
          ActiveRecord::Base.transaction do
            save_event!(message)
            account(message).update!(role: message.payload['data']['role']) if account
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      else
        # store events in DB or produce invalid event to "invalid-events-topic"
      end
    end
  end

  private

  def account(mesage)
    Account.find_by(public_id: message.payload['data']['public_id'])
  end

  def save_event!(message)
    # read and write are executed within one transaction to prevent using the stale version
    current_version = Event.where(stream_id: message.payload['data']['public_id']).maximum(:version) || 0
    Event.create!(
      stream_id: message.payload['data']['public_id'],
      version: current_version + 1,
      data: message.payload
    )
  end
end
