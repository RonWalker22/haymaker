# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

League.create!( name: 'Practice',
                player_id: 1,
                start_date: DateTime.now,
                end_date: 50.years.from_now,
                mode: 'Fantasy Friendly'
              )

4.times do |n|
  case n
  when 0 then name = 'GDAX'
  when 1 then name = 'Binance'
  when 2 then name = 'Hitbtc'
  when 3 then name = 'Gemini'
  end
  Exchange.create!( name: name )
  ExchangeLeague.create!( exchange_id: n+1, league_id: 1)
end

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

  4.times do |inner_n|
    Wallet.create!( coin_type: 'BTC',
                    coin_quantity: '1.00',
                    player_id: n + 1,
                    exchange_id: inner_n + 1,
                    league_id: 1,
                    public_key: SecureRandom.hex(20)
                  )
  end

  LeaguePlayer.create!( player_id: n + 1, league_id: 1)
end
