desc 'Close current billing cycles and create payout transactions'
task close_billing_cycles: :environment do
  Cycle.where(closed: false).find_in_batches do |group|
    group.each do |cycle|
      if cycle.amount.positive?
        ActiveRecord::Base.transaction do
          Transaction.create!(
            cycle:,
            transaction_type: :payout,
            billing_account: cycle.billing_account,
            debit: cycle.amount
          )
          cycle.update!(closed: true)
          Cycle.create!(billing_account: cycle.billing_account, amount: 0, closed: false)
        end
      else
        ActiveRecord::Base.transaction do
          # don't create payout transactin if cycle.amount is negative or zero
          cycle.update!(closed: true)
          Cycle.create!(billing_account: cycle.billing_account, amount: cycle.amount, closed: false)
        end
      end

      # ----------------------------- produce event -----------------------
      event = {
        event_name: 'CyclesClosed',
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_time: Time.now.to_s,
        producer: 'billing_service',
        data: {
          public_id: cycle.public_id,
          amount: cycle.amount,
          account: {
            public_id: cycle.billing_account.account.public_id
          }
        }
      }
      result = SchemaRegistry.validate_event(event, 'cycles.closed', version: 1)

      if result.success?
        WaterDrop::SyncProducer.call(event.to_json, topic: 'cycles')
      else
        Rails.logger.error('Invalid payload for "cycles" event: ' + result.failure.join('; '))
        # store events in DB or produce invalid event to "invalid-events-topic"
      end
      # --------------------------------------------------------------------
    rescue StandardError => e
      Rails.logger.error(e)
    end
  end
end
