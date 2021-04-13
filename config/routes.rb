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
  resources :users, :members
end

