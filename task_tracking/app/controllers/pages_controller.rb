# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    # TODO: change logic after auth implementation
    @current_user = UserAccount.first
  end
end
