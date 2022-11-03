# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    email { FFaker::Internet.unique.email }
    password { '7_777_777' }
    role { Account.roles.values.sample }
    full_name { FFaker::Name.name }
    position { FFaker::Company.position }
  end
end
