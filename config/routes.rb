Rails.application.routes.draw do
  require 'sidekiq/web'

  devise_for :users, controllers: { registrations: 'users/registrations' }

  mount ActionCable.server => '/cable'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  unauthenticated do
   root to: 'static_pages#about'
  end
  authenticated do
    root to: 'static_pages#about'
  end

  resources :exchanges
  resources :wallets

  get 'leagues/current'  => 'leagues#current', :as => 'current_leagues'
  get 'leagues/past'     => 'leagues#past',    :as => 'past_leagues'

  resources :leagues

  get  '/about'                                    => 'static_pages#about'
  post '/leagues/:id/join'                         => 'leagues#join',
                                                    :as => 'join'
  post '/leagues/:id/reset'                          => 'leagues#reset_funds'
  get  'leagues/:id/exchanges/:xid'                => 'exchanges#show',
                                                            :as => 'trade'
  post 'leagues/:id/exchanges/:xid/order'          => 'exchanges#order',
                                                            :as => 'order'
  get  'leagues/:id/balances'                      => 'leagues#balances',
                                                    :as => 'balances'
  get 'users'                                    => 'users#index',
                                                    :as => 'users'

  get 'users/:id'                                     => 'users#show',
                                                    :as => 'user'
  post 'leagues/:id/setup'                            => 'leagues#set_up',
                                                    :as => 'setup'

  delete 'leagues/:id/players/:pid'                => 'leagues#leave',
                                                    :as => 'leave'
  post 'league_invites/:id/:sid/:rid/create'      => 'league_invites#create',
                                                   :as => 'send_league_invite'
  post 'league_invites/:lid/decline'              => 'league_invites#decline',
                                                  :as => 'decline_league_invite'
  delete 'leagues/:lid/orders/:id'               => 'orders#destroy', :as => 'cancel_order'

  post 'leagues/:id/swing/:target'          => 'leagues#swing',  :as => 'swing'

  post 'leagues/:id/bet/:size'                    => 'leagues#bet',    :as => 'bet'

  post 'leagues/:id/deleverage'   => 'leagues#deleverage', :as => 'deleverage'

  post 'leagues/:id/shield'       => 'leagues#shield', :as => 'shield'
  post 'leagues/:id/auto_shield'  => 'leagues#auto_shield', :as => 'auto_shield'
end
