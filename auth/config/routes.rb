Rails.application.routes.draw do
  use_doorkeeper
  devise_for :accounts

  root 'accounts#index'
  resources :accounts, only: %i[index edit update destroy]
  get '/accounts/current', to: 'accounts#current'
end
