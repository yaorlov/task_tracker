# frozen_string_literal: true

class OauthSessionsController < ApplicationController
  def new
    redirect_to root_path if session[:account]
  end

  def create
    provider = params[:provider]
# => "keepa"
    payload = request.env['omniauth.auth']
# => {"provider"=>:keepa,
#  "uid"=>"aef77694-dc22-4e1e-ac3e-e4061014aaa5",
#  "info"=>
#   {"email"=>"admin@test.com",
#    "full_name"=>"Roseann Cole",
#    "position"=>"Sales Manager",
#    "active"=>true,
#    "role"=>"admin",
#    "public_id"=>"aef77694-dc22-4e1e-ac3e-e4061014aaa5"},
#  "credentials"=>
#   {"token"=>"dPGjofYIahmjttI7Vg2o-TRb7UjUJI9LPVlB8xp-2bU",
#    "expires_at"=>1630618075,
#    "expires"=>true},
#  "extra"=>{}}

#     TODO: update accounts table
#     account_params(payload)
# => {:public_id=>"aef77694-dc22-4e1e-ac3e-e4061014aaa5",
#  :full_name=>"Roseann Cole",
#  :email=>"admin@test.com",
#  :role=>"admin"}
# [8] pry(#<OauthSessionsController>)> UserAccount.new
# => #<UserAccount:0x00007fcbd54ceae8
#  id: nil,
#  first_name: nil,
#  last_name: nil,
#  email: nil,
#  created_at: nil,
#  updated_at: nil>

    account = find_by_auth(provider, payload)

    if account.nil?
      account = create_account_with_auth(provider, payload)

      # TODO: send something for newly created account
    end

    session[:account] = account

    redirect_to root_path

    # if not created
    # retirect_to login_path
  end

  def destroy
    session[:account] = nil

    redirect_to login_path
  end

  private

  def find_by_auth(provider, payload)
    Account.joins(:auth_identities).where(
      auth_identities: { provider: provider, login: auth_identity_params(payload)[:login] }
    ).first
  end

  def create_account_with_auth(provider, payload)
    ActiveRecord::Base.transaction do
      account = Account.create!(**account_params(payload))
      account.auth_identities.create!({ **auth_identity_params(payload), provider: provider })
    end
    account
  end

  def account_params(payload)
    {
      public_id: payload['info']['public_id'],
      full_name: payload['info']['full_name'],
      email: payload['info']['email'],
      role: payload['info']['role'],
    }
  end

  def auth_identity_params(payload)
    {
      uid: payload['uid'],
      token: payload['credentials']['token'],
      login: payload['info']['email']
    }
  end
end
