# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i[in_progress done]

  def index
    @tasks = Task.all.includes(:assignee)
  end

  def in_progress
    @task.in_progress!
    redirect_back(fallback_location: tasks_path)
  end

  def done
    @task.done!
    redirect_back(fallback_location: tasks_path)
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end
end
