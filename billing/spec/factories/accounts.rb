# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    email { FFaker::Internet.unique.email }
    role { Account.roles.values.sample }
    full_name { FFaker::Name.name }
    public_id { SecureRandom.uuid }

    transient do
      with_billing_account { true }
      tasks_count { 2 }
    end

    after :build do |account, evaluator|
      if evaluator.with_billing_account
        create :billing_account, account:, amount: 0
      end
    end
  end
end
