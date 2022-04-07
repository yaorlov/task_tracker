# frozen_string_literal: true

# TasksCreated, TasksUpdated, and TasksCompleted events are used to create the tasks projection
# All events from the "tasks" and "tasks-stream" topics are stored in the events table
# We need to store all events to create new projections or update the existing ones if the requirements change
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
          ActiveRecord::Base.transaction do
            save_event!(message)
            task = find_task(message)
            if task
              # update if a task was created by TasksUpdated or TasksCompleted event
              task.update!(description: message.payload['data']['description'])
            else
              Task.create!(
                description: message.payload['data']['description'],
                public_id: message.payload['data']['public_id']
              )
            end
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['TasksUpdated', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.updated', version: 1)

        if result.success?
          Rails.logger.info('TasksUpdated')
          ActiveRecord::Base.transaction do
            save_event!(message)
            task = find_task(message)
            if task
              task.update!(complete_price:  message.payload['data']['complete_price'])
            else
              # create if a TaskCreated event wasn't received yet
              Task.create!(
                complete_price: message.payload['data']['complete_price'],
                public_id: message.payload['data']['public_id']
              )
            end
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['TasksAssigned', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.assigned', version: 1)

        if result.success?
          Rails.logger.info('TasksAssigned')
          save_event!(message)
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['TasksCompleted', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.completed', version: 1)

        if result.success?
          Rails.logger.info('TasksCompleted')
          ActiveRecord::Base.transaction do
            save_event!(message)
            task = find_task(message)
            if task
              task.update!(completed_at: Time.now.utc)
            else
              # create if a TaskCreated event wasn't received yet
              Task.create!(
                completed_at: Time.now.utc,
                public_id: message.payload['data']['public_id']
              )
            end
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

  def find_task(message)
    Task.find_by(public_id: message.payload['data']['public_id'])
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
