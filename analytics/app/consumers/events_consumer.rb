# frozen_string_literal: true

# EventsConsumer stores all of the events that are not consumed in AccountChangesConsumer and CycleChangesConsumer
# we need all events to create new projections or
# update the existing ones if the requirements change
class EventsConsumer < ApplicationConsumer
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
          save_event(message)
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['TasksCompleted', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.completed', version: 1)

        if result.success?
          Rails.logger.info('TasksCompleted')
          save_event(message)
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['TasksCreated', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.created', version: 1)

        if result.success?
          Rails.logger.info('TasksCreated')
          save_event(message)
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['TasksUpdated', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.updated', version: 1)

        if result.success?
          Rails.logger.info('TasksUpdated')
          save_event(message)
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      else
        # store events in DB or produce invalid event to "invalid-events-topic"
      end
    end
  end

  private

  def save_event(message)
    # read and write are executed within one transaction to prevent using the stale version
    ActiveRecord::Base.transaction do
      current_version = Event.where(stream_id: message.payload['data']['public_id']).maximum(:version) || 0
      Event.create!(
        stream_id: message.payload['data']['public_id'],
        version: current_version + 1,
        data: message.payload
      )
    end
  end
end
