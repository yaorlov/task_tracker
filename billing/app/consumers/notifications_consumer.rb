# frozen_string_literal: true

class NotificationsConsumer < ApplicationConsumer
  def consume
    params_batch.each do |message|
      puts '-' * 80
      p message
      puts '-' * 80

      case [message.payload['event_name'], message.payload['event_version']]
      when ['CyclesClosed', 1]
        result = SchemaRegistry.validate_event(message.payload, 'cycles.closed', version: 1)

        if result.success?
          Rails.logger.info('CyclesClosed')
          # notify user
          account = Account.find_by!(public_id: message.payload['data']['account']['public_id'])
          Rails.logger.info(
            "Email. Address: #{account.email}. "\
            "Body: You earned #{message.payload['data']['amount']} today."
          )
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      else
        # store events in DB or produce invalid event to "invalid-events-topic"
      end
    end
  end
end
