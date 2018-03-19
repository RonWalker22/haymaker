Rails.application.routes.draw do

  resources :orders
  root 'players#index'
  
  resources :leagues
  resources :exchanges
  resources :wallets
  resources :players

  get     '/leaderboards'         => 'players#index'
  get     '/signup'               => 'players#new'
  get     '/login'                => 'sessions#new'
  post    '/login'                => 'sessions#create'
  delete  '/logout'               => 'sessions#destroy'
  get     '/about'                => 'static_pages#about'
  post    '/order'                => 'exchanges#order'
  post    '/join'                 => 'leagues#join'
  get     '/reset'                => 'leagues#request_reset'
  post    '/reset'                => 'leagues#reset_funds'

  # get 'profile' => 'players#'
  # get 'profile/edit' => 'players#'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
