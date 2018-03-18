# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

Exchange.create!( name: 'GDAX' )

Exchange.create!( name: 'Binance', 
                  maker_fee: '0.01',
                  taker_fee: '0.01'
                )

League.create!( name: 'Practice',
                player_id: 1,
                start_date: DateTime.now,
                end_date: 50.years.from_now,
                mode: 'Fantasy Friendly'
              )

ExchangeLeague.create!( exchange_id: 1, league_id: 1)
ExchangeLeague.create!( exchange_id: 2, league_id: 1)

20.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@gmail.com"
  password = "123"
  admin = false

  (name = 'Ron22') && (email = 'ron@gmail.com') && (admin = true) if n == 0
  (name = 'Tom22') && (email = 'tom@gmail.com')                   if n == 1

  Player.create!(username: name,
                 email: email,
                 password: password,
                 password_confirmation: password,
                 rank: n + 1,
                 admin: admin
                )

  Wallet.create!( coin_type: 'USD', 
                  coin_quantity: '100000.00', 
                  player_id: n + 1,
                  exchange_id: 1,
                  league_id: 1,
                  public_key: "usd#{n + 1}1" 
                )

  LeaguePlayer.create!( player_id: n + 1, league_id: 1)
end
