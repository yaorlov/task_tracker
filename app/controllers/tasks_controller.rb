# frozen_string_literal: true

class TasksController < ApplicationController
  def index
    @tasks = Task.all.includes(:assignee)
  end
end
