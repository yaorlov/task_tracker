# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    association :assignee, factory: :account, with_tasks: false, role: :worker

    description { FFaker::Lorem.sentence }
    status { Task.statuses.values.sample }
  end
end
