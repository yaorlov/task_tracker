# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @current_account = session[:account]
  end
end
