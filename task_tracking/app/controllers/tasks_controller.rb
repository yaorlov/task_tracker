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

    # ----------------------------- produce event -----------------------
    event = {
      event_name: 'TasksCompleted',
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.now.to_s,
      producer: 'task_tracking_service',
      data: {
        public_id: @task.public_id,
        status: @task.status,
      }
    }
    result = SchemaRegistry.validate_event(event, 'tasks.completed', version: 1)

    if result.success?
      WaterDrop::SyncProducer.call(event.to_json, topic: 'tasks')
    else
      logger.error('Invalid payload for "tasks" event: ' + result.failure.join('; '))
    end
    # --------------------------------------------------------------------

    redirect_back(fallback_location: tasks_path)
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end
end
