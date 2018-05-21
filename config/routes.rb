Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: 'users/registrations' }

  unauthenticated do
   root :to => 'users#index'
  end

  authenticated do
    root :to => 'leagues#index'
  end

  resources :leagues
  resources :exchanges
  resources :wallets

  get  '/leaderboards'                             => 'users#index'
  get  '/about'                                    => 'static_pages#about'
  post '/join'                                     => 'leagues#join'
  get  '/reset'                                    => 'leagues#request_reset'
  post '/reset'                                    => 'leagues#reset_funds'
  get  'leagues/:id/exchanges/:xid'                => 'exchanges#show',
                                                            :as => 'trade'
  post 'leagues/:id/exchanges/:xid/order'          => 'exchanges#order',
                                                            :as => 'order'
  get  'leagues/:id/exchanges/:xid/balances'        => 'exchanges#balances',
                                                            :as => 'balances'
  get  'leagues/:id/exchanges/:xid/withdrawal/:cid' => 'exchanges#withdrawal',
                                                            :as => 'withdrawal'
  post 'leagues/:id/exchanges/:xid/withdrawal/:cid' =>
                                                'exchanges#process_withdrawal',
                                                    :as => 'process_withdrawal'
  get 'leagues/:id/exchanges/:xid/transactions/:cid' =>
                                                'exchanges#transaction_history',
                                                    :as => 'transaction_history'
  get 'users'                                    => 'users#index',
                                                    :as => 'users'

  get 'users/:id'                                     => 'users#show',
                                                    :as => 'user'
  post 'league/setup'                                => 'leagues#set_up',
                                                    :as => 'setup'

  # get 'profile' => 'players#'
  # get 'profile/edit' => 'players#'

  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
