# frozen_string_literal: true

class Account < ApplicationRecord
  enum role: {
    admin: 'admin',
    manager: 'manager',
    finance: 'finance',
    worker: 'worker'
  }
end
