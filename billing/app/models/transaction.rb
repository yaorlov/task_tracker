# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum transaction_type: {
    task_completed: 'task_completed',
    task_assigned: 'task_assigned',
    payout: 'payout',
  }

  belongs_to :billing_account
  belongs_to :task, optional: true
end
