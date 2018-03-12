# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Player.create!(username: "Ron22",
#                email: "ron@gmail.com",
#                password: "123",
#                password_confirmation: "123",
#                admin: true,
#                rank: 3
#               )

# Player.create!(username: "Tom22",
#                email: "tom@gmail.com",
#                password: "123",
#                password_confirmation: "123",
#                admin: true,
#                rank: 4
#               )

Exchange.create!( name: 'GDAX' )


Exchange.create!( name: 'Binance', 
                  maker_fee: '0.01',
                  taker_fee: '0.01'
                )


20.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@gmail.com"
  password = "123"

  name = 'Ron22' && email = 'ron@gmail.com' if n == 0
  name = 'Tom22' && email = 'tom@gmail.com' if n == 1

  Player.create!(username: name,
                 email: email,
                 password: password,
                 password_confirmation: password,
                 rank: n + 1
                )

  Wallet.create!(coin_type: 'btc', 
                coin_quantity: '5.0', 
                player_id: n + 1,
                exchange_id: 1,
                public_key: "btc#{n + 1}1" 
                )

  Wallet.create!(coin_type: 'btc', 
                coin_quantity: '5.0', 
                player_id: n + 1,
                exchange_id: 2,
                public_key: "btc#{n + 1}2"
                )
end
