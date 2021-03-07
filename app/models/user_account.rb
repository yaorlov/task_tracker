# frozen_string_literal: true

class UserAccount < ApplicationRecord
  has_many :tasks, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end
end
