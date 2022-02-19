# frozen_string_literal: true

class TaskChangesConsumer < ApplicationConsumer
  def consume
    params_batch.each do |message|
      puts '-' * 80
      p message
      puts '-' * 80

      account = Account.find_by(public_id: message.payload.dig('data', 'assignee', 'public_id'))

      case [message.payload['event_name'], message.payload['event_version']]
      when ['TasksCreated', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.created', version: 1)

        if result.success?
          Rails.logger.info('TasksCreated')

          if account
            Task.create!(
              **message.payload['data'].except('assignee'),
              assignee: account,
              assign_price: rand(10..20) * 100,
              complete_price: rand(20..40) * 100
            )
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
          billing_account = account&.billing_account

          if task.nil?
            Rails.logger.error("Task with public_id #{message.payload['data']['public_id']} doesn't exist")
            return
          end

          if billing_account.nil?
            Rails.logger.error("BillingAccount for account with public_id #{message.payload.dig('data', 'assignee', 'public_id')} doesn't exist")
            return
          end

          ActiveRecord::Base.transaction do
            account.billing_account.update!(amount: account.billing_account.amount - task.assign_price)
            cycle = Cycle.find_or_create_by!(closed: false, billing_account: account.billing_account)
            transaction = Transaction.create!(credit: task.assign_price, transaction_type: :task_assigned, task:, billing_account:, cycle:) # attach cycle?
            cycle.update!(amount: cycle.amount - task.assign_price)
          end
        else
          # store events in DB or produce invalid event to "invalid-events-topic"
        end
      when ['TasksCompleted', 1]
        result = SchemaRegistry.validate_event(message.payload, 'tasks.completed', version: 1)

        if result.success?
          Rails.logger.info('TasksCompleted')
          task = Task.find_by(public_id: message.payload['data']['public_id'])
          billing_account = account&.billing_account

          if task.nil?
            Rails.logger.error("Task with public_id #{message.payload['data']['public_id']} doesn't exist")
            return
          end

          if billing_account.nil?
            Rails.logger.error("BillingAccount for account with public_id #{message.payload.dig('data', 'assignee', 'public_id')} doesn't exist")
            return
          end

          ActiveRecord::Base.transaction do
            account.billing_account.update!(amount: account.billing_account.amount + task.complete_price)
            cycle = Cycle.find_or_create_by!(closed: false, billing_account: account.billing_account)
            transaction = Transaction.create!(debit: task.complete_price, transaction_type: :task_completed, task:, billing_account:, cycle:)
            cycle.update!(amount: cycle.amount + task.complete_price)
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
