Rails.application.routes.draw do
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
  get '/incomes/delete', to: 'incomes#destroy'
  delete '/incomes/delete', to: 'incomes#destroy'
  get '/expenses', to: 'expenses#new'
  post '/expenses', to: 'expenses#create'
  get '/expenses/delete', to: 'expenses#destroy'
  delete '/expenses/delete', to: 'expenses#destroy'
  resources :users, :members
end

