# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i[in_progress done]
  before_action :set_current_account, only: %i[index new create]

  def index
    return redirect_to login_path unless session[:account]

    @tasks = Task.all.includes(:assignee)
  end

  def new
    return redirect_to login_path unless session[:account]

    @task = Task.new
  end

  def create
    @task = Task.new(task_params)

    if @task.valid?
      @task.save!
      @task.reload # reload is needed to get the assigned public_id

      # ----------------------------- produce event -----------------------
      event = {
        event_name: 'TasksCreated',
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_time: Time.now.to_s,
        producer: 'task_tracking_service',
        data: {
          public_id: @task.public_id,
          description: @task.description,
          status: @task.status,
          assignee: {
            public_id: @task.assignee.public_id
          }
        }
      }
      result = SchemaRegistry.validate_event(event, 'tasks.created', version: 1)

      if result.success?
        WaterDrop::SyncProducer.call(event.to_json, topic: 'tasks-stream')
      else
        logger.error('Invalid payload for "tasks" event: ' + result.failure.join('; '))
      end
      # --------------------------------------------------------------------
    
      redirect_to tasks_path
    else
      render :new
    end
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

  def reassign
    tasks = Task.in_progress.select(:id, :public_id, :description, :status, :created_at).as_json
    account_ids = Account.worker.pluck(:id, :public_id).to_h
    payload = tasks.map { |task| task.merge(account_id: account_ids.keys.sample) }
    result = Task.upsert_all(payload, unique_by: :id, returning: %i[public_id account_id])

    # ignore failed updates from upsert_all for simplicity
    result.rows.each do |public_id, account_id|
      # ----------------------------- produce event -----------------------
      event = {
        event_name: 'TasksAssigned',
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_time: Time.now.to_s,
        producer: 'task_tracking_service',
        data: {
          public_id: public_id,
          assignee: {
            public_id: account_ids[account_id]
          }
        }
      }
      result = SchemaRegistry.validate_event(event, 'tasks.assigned', version: 1)

      if result.success?
        WaterDrop::AsyncProducer.call(event.to_json, topic: 'tasks')
      else
        logger.error('Invalid payload for "tasks" event: ' + result.failure.join('; '))
      end
      # --------------------------------------------------------------------
    end

    redirect_to tasks_path
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_current_account
    @current_account = session[:account]
  end

   # Only allow a list of trusted parameters through.
   def task_params
    params.require(:task).permit(:description, :account_id)
  end
end
