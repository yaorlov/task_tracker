# frozen_string_literal: true

class Cycle < ApplicationRecord
  belongs_to :billing_account
  has_many :transactions
end
