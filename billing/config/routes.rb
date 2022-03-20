Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'pages#home'

  get '/login', to: 'oauth_sessions#new'
  get '/logout', to: 'oauth_sessions#destroy'
  get '/auth/:provider/callback', to: 'oauth_sessions#create', as: 'oauth_callback'
end
