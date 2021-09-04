# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_account

  def tasks
    @tasks = Task.where(assignee: @account).includes(:assignee)
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
