# frozen_string_literal: true

FactoryBot.define do
  factory :user_account do
    email { FFaker::Internet.unique.email }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }

    transient do
      with_tasks { false }
      tasks_count { 2 }
    end

    after(:build) do |user_account, evaluator|
      create_list(:task, evaluator.tasks_count, assignee: user_account) if evaluator.with_tasks
    end
  end
end
