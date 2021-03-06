# frozen_string_literal: true

class UserAccount < ApplicationRecord
  has_many :tasks, dependent: :destroy
end
