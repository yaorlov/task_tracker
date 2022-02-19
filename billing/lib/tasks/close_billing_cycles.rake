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
    end
  end
end
