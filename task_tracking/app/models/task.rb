# frozen_string_literal: true

class Task < ApplicationRecord
  enum status: { in_progress: 0, done: 1 }

  validates :status, inclusion: { in: statuses.keys }
  validates :description, presence: true

  belongs_to :assignee, class_name: 'Account', foreign_key: :account_id, inverse_of: :tasks
end
