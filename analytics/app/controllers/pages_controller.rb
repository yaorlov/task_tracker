# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    return redirect_to login_path unless session[:account]

    @current_account = session[:account]
    @management_income = ManagementIncome.where(created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day)
                                         .sum(:amount) / 100.0

    if @current_account['role'] == Account.roles[:admin]
      flash.now[:info] = 'Welcome!'
    else
      flash.now[:danger] = 'You are not authorized to use billing dashboard'
    end
  end
end
