# frozen_string_literal: true

module Accounts
  class FindOrCreateByAuthService
    include Dry::Monads[:result, :do, :try]

    def call(provider:, auth_data:)
      # if account was created with auth_entity
      account_by_auth = find_by_auth(provider, auth_data)
      return Success(account_by_auth) if account_by_auth

      # if account was created without auth_entity (on 'AccountCreated' event)
      account_by_email = Account.find_by(email: auth_data['info']['email'])
      if account_by_email
        yield create_auth_identity!(auth_data, provider, account_by_email)
        return Success(account_by_email)
      end

      # if account does not exist
      ActiveRecord::Base.transaction do
        account = yield create_account!(auth_data)
        yield create_auth_identity!(auth_data, provider, account)
        yield create_billing_account!(account)
        Success(account)
      end
    end

    private

    def find_by_auth(provider, auth_data)
      Account.joins(:auth_identities).where(
        auth_identities: { provider: provider, login: auth_data['info']['email'] }
      ).first
    end

    def create_account!(auth_data)
      Try do
        Account.create!(
          public_id: auth_data['info']['public_id'],
          full_name: auth_data['info']['full_name'],
          email: auth_data['info']['email'],
          role: auth_data['info']['role']
        )
      end.to_result
    end

    def create_billing_account!(account)
      Try do
        BillingAccount.create!(account:)
      end.to_result
    end

    def create_auth_identity!(auth_data, provider, account)
      Try do
        account.auth_identities.create!(
          uid: auth_data['uid'],
          token: auth_data['credentials']['token'],
          login: auth_data['info']['email'],
          provider: provider
        )
      end.to_result
    end
  end
end
