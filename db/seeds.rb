# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
40.times do |n|
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
  if n == 0
    League.create!( name: 'Practice',
                    commissioner_id: 1,
                    balance_revivable: true,
                    start_date: Time.now,
                    end_date: 1000.years.from_now,
                    round_end: 1000.years.from_now,
                    round_steps: 1000,
                    rounds: 100,
                    round: 2
                  )

    Exchange.create!( name: 'Binance' )
    ExchangeLeague.create!( exchange_id: 1, league_id: 1)
  end

  LeagueUser.create!(user_id: n + 1, league_id: 1, set_up: true, ready: true)

  Wallet.create!( coin_type: 'ETH',
                  total_quantity: [10, 20, 30, 25, 35, 40].sample,
                  exchange_id: 1,
                  league_user_id: n + 1,
                  public_key: SecureRandom.hex(20)
                )

  Wallet.create!( coin_type: 'BTC',
                  total_quantity: [1, 1.1, 1.2, 1.3, 1.6, 1.7, 1.8, 2].sample,
                  exchange_id: 1,
                  league_user_id: n + 1,
                  public_key: SecureRandom.hex(20)
                )

end

League.create!( name: 'Second',
                commissioner_id: 1,
                balance_revivable: true,
                start_date: Time.now,
                end_date: 100.years.from_now,
                round_end: 1000.years.from_now,
                round_steps: 1000,
              )
ExchangeLeague.create!( exchange_id: 1, league_id: 2)
2.times do |n|
  LeagueInvite.create!(receiver_id: n + 2, sender_id: n + 1, league_id: 2)
end

Wallet.create!( coin_type: 'LTC',
                total_quantity: 4.8394828,
                exchange_id: 1,
                league_user_id: 1,
                public_key: SecureRandom.hex(20)
              )
Wallet.create!( coin_type: 'ADA',
                total_quantity: 5000.8459,
                exchange_id: 1,
                league_user_id: 1,
                public_key: SecureRandom.hex(20)
              )
Wallet.create!( coin_type: 'XRP',
                total_quantity: 100.989797,
                exchange_id: 1,
                league_user_id: 1,
                public_key: SecureRandom.hex(20)
              )
Wallet.create!( coin_type: 'LTC',
                total_quantity: 12.98979,
                exchange_id: 1,
                league_user_id: 4,
                public_key: SecureRandom.hex(20)
              )
Wallet.create!( coin_type: 'LTC',
                total_quantity: 5.9897,
                exchange_id: 1,
                league_user_id: 3,
                public_key: SecureRandom.hex(20)
              )
Wallet.create!( coin_type: 'LTC',
                total_quantity: 15.99797,
                exchange_id: 1,
                league_user_id: 2,
                public_key: SecureRandom.hex(20)
              )

Leverage.create!(size: 2,   liquidation: 0.331)
Leverage.create!(size: 3,   liquidation: 0.2472)
Leverage.create!(size: 5,   liquidation: 0.1632)
Leverage.create!(size: 10,  liquidation: 0.0867)
Leverage.create!(size: 25,  liquidation: 0.0338)
Leverage.create!(size: 50,  liquidation: 0.0147)
Leverage.create!(size: 100, liquidation: 0.0049)

UpgradeType.create!(name:'Oracle', cost:100, level:2)
UpgradeType.create!(name:'Block', cost:10, level:1)
UpgradeType.create!(name:'Bull', cost:10, level:1)
UpgradeType.create!(name:'Double spend', cost:10, level:1)
UpgradeType.create!(name:'Encryption', cost:10, level:1)
UpgradeType.create!(name:'Decryption', cost:10, level:1)
UpgradeType.create!(name:'Satoshi', cost:1000, level:3, burn:true)

Reward.create!(name:"Champ of the Day", size:10)
Reward.create!(name:"Champ of the Week", size:70)
Reward.create!(name:"Champ of the Month", size:300)
Reward.create!(name:"Champ of the Quarter", size:900)
Reward.create!(name:"Champ of the Year", size:3600)
Reward.create!(name:"Round Survivor", size:1, long_term:false)
Reward.create!(name:"Firefight Champ", size:3, long_term:false)
Reward.create!(name:"King to the Hill", size:5, long_term:false)
