# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    association :assignee, factory: :user_account, with_tasks: false

    description { FFaker::Lorem.sentence }
    status { [0, 1].sample }
  end
end
