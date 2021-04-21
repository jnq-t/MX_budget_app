Rails.application.routes.draw do
  # get 'incomes/new'
  # get 'incomes/create'
  # get 'incomes/destroy'
  get 'sessions/new'
  get 'members/new'
  get 'users/new'
  root 'static_pages#home'
  get '/settings', to: 'static_pages#settings'
  get '/signup', to: 'users#new'
  get '/members', to: 'members#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/incomes', to: 'incomes#new'
  post '/incomes', to: 'incomes#create'
  delete '/incomes', to: 'incomes#destroy'
  resources :users, :members
end

