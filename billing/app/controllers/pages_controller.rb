# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    return redirect_to login_path unless session[:account]

    @current_account = session[:account]
    @today_revenue = Cycle.where(closed: false).sum(:amount) * -1
  end
end
