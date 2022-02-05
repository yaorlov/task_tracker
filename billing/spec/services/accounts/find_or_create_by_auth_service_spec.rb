require 'rails_helper'

RSpec.describe Accounts::FindOrCreateByAuthService, type: :service do
  subject(:call_service) do
    described_class.new.call(provider: 'keepa', auth_data: auth_data)
  end

  let(:public_id) { SecureRandom.uuid }
  let(:auth_data) do
    {
      "provider"=>:keepa,
      "uid"=>public_id,
      "info"=>
        {"email"=>"admin@test.com",
        "full_name"=>"Roseann Cole",
        "position"=>"Sales Manager",
        "active"=>true,
        "role"=>"admin",
        "public_id"=>public_id},
      "credentials"=>
        {"token"=>"8ILIcX2wYICjy1LI1jSDrHuRjRnx6d4GoL6GaBP-lR0",
        "expires_at"=>1633270077,
        "expires"=>true},
      "extra"=>{}
    }
  end

  context 'when account does not exist' do
    it 'creates a new account with auth identity and billing_account' do
      expect { call_service }.to change { Account.where(public_id: public_id).count }.from(0).to(1).and \
        change { AuthIdentity.where(uid: public_id).count }.from(0).to(1).and \
        change { BillingAccount.where(account_id: Account.find_by(public_id: public_id)&.id).count }.from(0).to(1)
    end

    it 'returns success with new account as a value' do
      result = call_service
      expect(result).to be_success
      expect(result.value!).to eq Account.find_by(public_id: public_id)
    end
  end

  context 'when account and auth_identity already exist' do
    let(:account) { create(:account, email: 'admin@test.com', public_id: public_id) }

    before do
      auth_identity = create(:auth_identity, account: account, provider: 'keepa', login: "admin@test.com")
    end

    it 'does not create a new account with auth identity' do
      expect { call_service }.to not_change { Account.where(public_id: public_id).count }.and \
        not_change { AuthIdentity.where(uid: public_id).count }
    end

    it 'returns success with existing account as a value' do
      result = call_service
      expect(result).to be_success
      expect(result.value!).to eq(account)
    end
  end

  context 'when account without auth_identity already exists' do
    let(:account) { create(:account, email: 'admin@test.com', public_id: public_id) }

    before { account }

    it 'does not create a new account' do
      expect { call_service }.to not_change { Account.where(public_id: public_id).count }
    end

    it 'creates auth identity' do
      expect { call_service }.to change { AuthIdentity.where(uid: public_id).count }.from(0).to(1)
    end

    it 'returns success with existing account as a value' do
      result = call_service
      expect(result).to be_success
      expect(result.value!).to eq(account)
    end
  end

  context 'when auth_identity params are invalid' do
    let(:auth_data) do
      {
        "provider"=>:keepa,
        "uid"=>public_id,
        "info"=>
          {"email"=>"admin@test.com",
          "full_name"=>"Roseann Cole",
          "position"=>"Sales Manager",
          "active"=>true,
          "role"=>"admin",
          "public_id"=>public_id},
        "credentials"=>
          {"token"=>nil,
          "expires_at"=>1633270077,
          "expires"=>true},
        "extra"=>{}
      }
    end

    it 'does not create account and auth identity' do
      expect { call_service }.to not_change { Account.where(public_id: public_id).count }.and \
        not_change { AuthIdentity.where(uid: public_id).count }
    end

    it 'returns failure' do
      result = call_service

      expect(result).to be_failure
    end
  end
end
