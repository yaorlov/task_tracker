# frozen_string_literal: true

class AccountChangesConsumer < ApplicationConsumer
  def consume
    params_batch.each do |message|
      puts '-' * 80
      p message
      puts '-' * 80

      account = Account.find_by(public_id: message.payload['data']['public_id'])

      case [message.payload['event_name'], message.payload['event_version']]
      when ['AccountsCreated', 1]
        result = SchemaRegistry.validate_event(message.payload, 'accounts.created', version: 1)

        if result.success?
          Rails.logger.info('AccountsCreated')
          Account.create!(message.payload['data'])
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['AccountsUpdated', 1]
        return unless account

        result = SchemaRegistry.validate_event(message.payload, 'accounts.updated', version: 1)

        if result.success?
          Rails.logger.info('AccountsUpdated')
          account.update(full_name: message.payload['data']['full_name'])
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['AccountsDeleted', 1]
        return unless account

        result = SchemaRegistry.validate_event(message.payload, 'accounts.deleted', version: 1)

        if result.success?
          Rails.logger.info('AccountsDeleted')
          account.destroy
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['AccountsRoleChanged', 1]
        return unless account

        result = SchemaRegistry.validate_event(message.payload, 'accounts.role_changed', version: 1)

        if result.success?
          Rails.logger.info('AccountsRoleChanged')
          account.update(role: message.payload['data']['role'])
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      else
        # store events in DB or produce invalid event to "invalid-events-topic"
      end
    end
  end
end
