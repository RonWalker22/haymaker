# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

User.create!(name: 'Ron',
             email: 'ron@gmail.com',
             password: '123456',
             password_confirmation: '123456',
            )

League.create!( name: 'Practice',
                commissioner_id: 1,
                balance_revivable: true,
                start_date: Time.now,
                end_date: 1000.years.from_now,
                swing_by: 1000.years.from_now,
                round_end: 1000.years.from_now,
                round_steps: 1000,
                rounds: 1,
                round: 1
              )

Exchange.create!( name: 'Binance' )
ExchangeLeague.create!( exchange_id: 1, league_id: 1)

LeagueUser.create!(user_id: 1, league_id: 1, set_up: true,
                  ready: true, baseline: 10_000)



Wallet.create!( coin_type: 'BTC',
                total_quantity: 1,
                exchange_id: 1,
                league_user_id: 1,
                public_key: SecureRandom.hex(20)
              )

Leverage.create!(size: 2,   liquidation: 0.331)
Leverage.create!(size: 3,   liquidation: 0.2472)
Leverage.create!(size: 5,   liquidation: 0.1632)
Leverage.create!(size: 10,  liquidation: 0.0867)
Leverage.create!(size: 25,  liquidation: 0.0338)
Leverage.create!(size: 50,  liquidation: 0.0147)
Leverage.create!(size: 100, liquidation: 0.0049)

GetTickersJob.perform_later
