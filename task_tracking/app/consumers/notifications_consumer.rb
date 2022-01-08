# frozen_string_literal: true

class NotificationsConsumer < ApplicationConsumer
  def consume
    params_batch.each do |message|
      puts '-' * 80
      p message
      puts '-' * 80

      case [message.payload['event_name'], message.payload['event_version']]
      when ['TasksAssigned', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.assigned', version: 1)

        if result.success?
          Rails.logger.info('TasksAssigned')
          # notify user
          account = Account.find_by!(public_id: message.payload['data']['assignee']['public_id'])
          Rails.logger.info("Email: #{account.full_name}, there is a new task assigned to you")
          Rails.logger.info("SMS: #{account.full_name}, there is a new task assigned to you")
          Rails.logger.info("Slack: #{account.full_name}, there is a new task assigned to you")
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      else
        # store events in DB or produce invalid event to "invalid-events-topic"
      end
    end
  end
end
