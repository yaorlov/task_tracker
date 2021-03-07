# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tasks, only: [:index]

  # resources :user_accounts, as: :users do
  #   member do
  #     get :tasks
  #   end
  # end
  get '/users/:user_account_id/tasks', to: 'user_accounts#tasks'
  patch '/tasks/:task_id/in_progress', to: 'tasks#in_progress'
  patch '/tasks/:task_id/done', to: 'tasks#done'
end
