Rails.application.routes.draw do
  get 'users/new'
  root 'static_pages#home'
  get '/settings', to: 'static_pages#settings'
  get '/signup', to: 'users#new'
end
