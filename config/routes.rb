# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tasks, only: [:index]

  # resources :user_accounts, as: :users do
  #   member do
  #     get :tasks
  #   end
  # end
  get '/users/:user_account_id/tasks', to: 'user_accounts#tasks'
end
