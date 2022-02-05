# frozen_string_literal: true

FactoryBot.define do
  factory :billing_account do
    association :account, with_billing_account: false

    amount { rand(0..10_000) }
  end
end
