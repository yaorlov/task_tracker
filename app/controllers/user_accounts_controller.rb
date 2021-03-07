# frozen_string_literal: true

class UserAccountsController < ApplicationController
  before_action :set_user_account

  def tasks
    @tasks = Task.where(assignee: @user_account).includes(:assignee)
  end

  private

  def set_user_account
    @user_account = UserAccount.find(params[:user_account_id])
  end
end
