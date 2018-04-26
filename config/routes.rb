Rails.application.routes.draw do

  # resources :orders
  root 'players#index'

  resources :leagues
  resources :exchanges
  resources :wallets
  resources :players

  get     '/leaderboards'                             => 'players#index'
  get     '/signup'                                   => 'players#new'
  get     '/login'                                    => 'sessions#new'
  post    '/login'                                    => 'sessions#create'
  delete  '/logout'                                   => 'sessions#destroy'
  get     '/about'                                    => 'static_pages#about'
  post    '/join'                                     => 'leagues#join'
  get     '/reset'                                    => 'leagues#request_reset'
  post    '/reset'                                    => 'leagues#reset_funds'
  get     'leagues/:id/exchanges/:xid'                => 'exchanges#show',
                                                            :as => 'trade'
  post    'leagues/:id/exchanges/:xid/order'          => 'exchanges#order',
                                                            :as => 'order'
  get    'leagues/:id/exchanges/:xid/balances'        => 'exchanges#balances',
                                                            :as => 'balances'
  get    'leagues/:id/exchanges/:xid/withdrawal/:cid' => 'exchanges#withdrawal',
                                                            :as => 'withdrawal'
  post   'leagues/:id/exchanges/:xid/withdrawal/:cid' =>
                                                'exchanges#process_withdrawal',
                                                    :as => 'process_withdrawal'
  get   'leagues/:id/exchanges/:xid/transactions/:cid' =>
                                                'exchanges#transaction_history',
                                                    :as => 'transaction_history'

  # get 'profile' => 'players#'
  # get 'profile/edit' => 'players#'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
