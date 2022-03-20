# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    return redirect_to login_path unless session[:account]

    @current_account = session[:account]

    if @current_account['role'] == Account.roles[:admin]
      flash.now[:info] = 'Welcome!'
    else
      flash.now[:danger] = 'You are not authorized to use billing dashboard'
    end
  end
end
