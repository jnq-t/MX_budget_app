Rails.application.routes.draw do
  get 'members/new'
  get 'users/new'
  root 'static_pages#home'
  get '/settings', to: 'static_pages#settings'
  get '/signup', to: 'users#new'
  get '/members', to: 'members#index'
  resources :users, :members
end

