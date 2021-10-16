# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    email { FFaker::Internet.unique.email }
    role { Account.roles.values.sample }
    full_name { FFaker::Name.name }
    public_id { SecureRandom.uuid }

    transient do
      with_tasks { false }
      tasks_count { 2 }
    end

    after(:build) do |account, evaluator|
      create_list(:task, evaluator.tasks_count, assignee: account) if evaluator.with_tasks
    end
  end
end
