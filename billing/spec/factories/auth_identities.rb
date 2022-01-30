# frozen_string_literal: true

FactoryBot.define do
  factory :auth_identity do
    account
    uid { SecureRandom.uuid }
    token { SecureRandom.uuid }
    login { FFaker::Internet.unique.email }
    provider { :keepa }
  end
end
