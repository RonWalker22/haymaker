Rails.application.routes.draw do
  
  root 'players#index'

  resources :players

  get '/leaderboards' => 'players#index'
  get '/signup' => 'players#new'
  get '/login' =>  'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  # get 'profile' => 'players#'
  # get 'profile/edit' => 'players#'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
