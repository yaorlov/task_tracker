# frozen_string_literal: true

Rails.application.routes.draw do
  root 'pages#home'

  resources :tasks, only: %i[index new create]
  resources :accounts, only: [] do
    member do
      get :tasks
    end
  end

  patch '/tasks/:task_id/in_progress', to: 'tasks#in_progress'
  patch '/tasks/:task_id/done', to: 'tasks#done'
  patch '/tasks/reassign', to: 'tasks#reassign'

  get '/login', to: 'oauth_sessions#new'
  get '/logout', to: 'oauth_sessions#destroy'
  get '/auth/:provider/callback', to: 'oauth_sessions#create', as: 'oauth_callback'
end
