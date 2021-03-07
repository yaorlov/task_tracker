# frozen_string_literal: true

Rails.application.routes.draw do
  root 'pages#home'

  resources :tasks, only: [:index]
  resources :user_accounts, as: :user, path: 'user', only: [] do
    member do
      get :tasks
    end
  end

  patch '/tasks/:task_id/in_progress', to: 'tasks#in_progress'
  patch '/tasks/:task_id/done', to: 'tasks#done'
end
