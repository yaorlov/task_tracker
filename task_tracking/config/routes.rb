# frozen_string_literal: true

Rails.application.routes.draw do
  root 'pages#home'

  resources :tasks, only: [:index]
  resources :accounts, only: [] do
    member do
      get :tasks
    end
  end

  patch '/tasks/:task_id/in_progress', to: 'tasks#in_progress'
  patch '/tasks/:task_id/done', to: 'tasks#done'

  get '/login', to: 'oauth_sessions#new'
  get '/logout', to: 'oauth_sessions#destroy'
  get '/auth/:provider/callback', to: 'oauth_sessions#create'
end
