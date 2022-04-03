# frozen_string_literal: true

# CycleChangesConsumer consumes CyclesClosed events for management_incomes projection and
# stores CyclesClosed events in the events table
class CycleChangesConsumer < ApplicationConsumer
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
          cycle_amount = message.payload['data']['amount']
          ActiveRecord::Base.transaction do
            save_event!(message)
            # according to business logic, employee's financial loss is employer's income
            # so we filter negative amounts only
            ManagementIncome.create!(amount: -cycle_amount) if cycle_amount.negative?
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
