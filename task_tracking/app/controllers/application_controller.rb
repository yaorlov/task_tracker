# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :danger, :info, :warning, :success, :messages
end
