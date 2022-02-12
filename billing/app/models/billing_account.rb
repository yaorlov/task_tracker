# frozen_string_literal: true

class BillingAccount < ApplicationRecord
  belongs_to :account

  has_many :transactions, dependent: :destroy
end
