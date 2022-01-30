# frozen_string_literal: true

class AuthIdentity < ApplicationRecord
  belongs_to :account
end
