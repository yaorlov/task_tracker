# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    return redirect_to login_path unless session[:account]

    @current_account = session[:account]

    if %w[admin finance].include?(@current_account['role'])
      @today_revenue = Cycle.where(closed: false).sum(:amount) * -1
    else
      flash.now[:danger] = 'You are not authorized to use billing dashboard'
    end
  end
end
