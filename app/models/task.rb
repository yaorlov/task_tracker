# frozen_string_literal: true

class Task < ApplicationRecord
  enum status: { in_progress: 0, done: 1 }

  belongs_to :assignee, class_name: 'UserAccount', foreign_key: :user_account_id, inverse_of: :tasks
end
