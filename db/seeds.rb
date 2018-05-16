# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

Exchange.create!( name: 'Binance' )

League.create!( name: 'Practice', user_id: 1, start_date: DateTime.now,
                end_date: 100.years.from_now,
              )

ExchangeLeague.create!( exchange_id: 1, league_id: 1)

7.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@gmail.com"
  password = "123456"
  admin = false

  (name = 'Ron22') && (email = 'ron@gmail.com') && (admin = true) if n == 0
  (name = 'Tom22') && (email = 'tom@gmail.com')                   if n == 1

  User.create!(name: name,
                 email: email,
                 password: password,
                 password_confirmation: password,
                 admin: admin
                )

  Wallet.create!( coin_type: 'BTC',
                  coin_quantity: '1.00',
                  user_id: n + 1,
                  exchange_id: 1,
                  league_id: 1,
                  public_key: SecureRandom.hex(20)
                )

  LeagueUser.create!( user_id: n + 1, league_id: 1)
end
