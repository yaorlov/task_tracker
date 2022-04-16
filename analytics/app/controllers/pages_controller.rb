# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    return redirect_to login_path unless session[:account]

    @current_account = session[:account]
    @management_income = ManagementIncome.where(created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day)
                                         .sum(:amount) / 100.0

    @most_expensive_task_today = most_expensive_task(DateTime.now.beginning_of_day..DateTime.now.end_of_day)
    @most_expensive_task_this_week = most_expensive_task(DateTime.now.beginning_of_week..DateTime.now.end_of_week)
    @most_expensive_task_this_month = most_expensive_task(DateTime.now.beginning_of_month..DateTime.now.end_of_month)

    if @current_account['role'] == Account.roles[:admin]
      flash.now[:info] = 'Welcome!'
    else
      flash.now[:danger] = 'You are not authorized to use analytics dashboard'
    end
  end

  private

  def most_expensive_task(range)
    Task.where(completed_at: range).order(complete_price: :desc).first
  end
end
