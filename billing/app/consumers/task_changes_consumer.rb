# frozen_string_literal: true

class TaskChangesConsumer < ApplicationConsumer
  def consume
    params_batch.each do |message|
      puts '-' * 80
      p message
      puts '-' * 80


      case [message.payload['event_name'], message.payload['event_version']]
      when ['TasksCreated', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.created', version: 1)

        if result.success?
          Rails.logger.info('TasksCreated')
          account = Account.find_by(public_id: message.payload['data']['assignee']['public_id'])

          if account
            Task.create!(**message.payload['data'].except('assignee'), assignee: account)
          else
            Rails.logger.error("Account with public_id #{message.payload['data']['assignee']['public_id']} doesn't exist")
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['TasksAssigned', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.assigned', version: 1)

        if result.success?
          Rails.logger.info('TasksAssigned')
          task = Task.find_by(public_id: message.payload['data']['public_id'])

          if task
            task.update!(assign_price: rand(-20..-10))
          else
            Rails.logger.error("Task with public_id #{message.payload['data']['public_id']} doesn't exist")
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      else
        # store events in DB or produce invalid event to "invalid-events-topic"
      end
    end
  end
end
