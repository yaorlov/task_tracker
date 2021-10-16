# frozen_string_literal: true

class OauthSessionsController < ApplicationController
  def new
    redirect_to root_path if session[:account]
  end

  def create
    result = Accounts::FindOrCreateByAuthService.new.call(
      provider: params[:provider],
      auth_data: request.env['omniauth.auth']
    )

    case result
    in Dry::Monads::Result::Success(Account)
      session[:account] = result.value!
      redirect_to root_path
    in Dry::Monads::Result::Failure
      flash[:error] = 'Login failed'
      redirect_to login_path
    end
  end

  def destroy
    session[:account] = nil

    redirect_to login_path
  end
end
