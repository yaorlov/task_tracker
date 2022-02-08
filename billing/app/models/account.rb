# frozen_string_literal: true

class Account < ApplicationRecord
  enum role: {
    admin: 'admin',
    manager: 'manager',
    finance: 'finance',
    worker: 'worker'
  }

  has_many :auth_identities, dependent: :destroy
  has_many :tasks, dependent: :destroy

  has_one :billing_account
end
