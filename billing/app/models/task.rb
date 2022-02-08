# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :assignee, class_name: 'Account', foreign_key: :account_id, inverse_of: :tasks
end
