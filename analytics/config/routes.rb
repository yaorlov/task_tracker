Rails.application.routes.draw do
  root 'pages#home'

  get '/login', to: 'oauth_sessions#new'
  get '/logout', to: 'oauth_sessions#destroy'
  get '/auth/:provider/callback', to: 'oauth_sessions#create', as: 'oauth_callback'
end
