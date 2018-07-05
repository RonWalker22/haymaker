# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180702021858) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bets", force: :cascade do |t|
    t.bigint "leverage_id", null: false
    t.bigint "league_user_id", null: false
    t.decimal "baseline", null: false
    t.decimal "liquidation", null: false
    t.decimal "post_value", null: false
    t.integer "round", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_user_id"], name: "index_bets_on_league_user_id"
    t.index ["leverage_id"], name: "index_bets_on_leverage_id"
    t.index ["round", "league_user_id"], name: "index_bets_on_round_and_league_user_id", unique: true
  end

  create_table "exchange_leagues", force: :cascade do |t|
    t.bigint "exchange_id", null: false
    t.bigint "league_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_id", "league_id"], name: "index_exchange_leagues_on_exchange_id_and_league_id", unique: true
    t.index ["exchange_id"], name: "index_exchange_leagues_on_exchange_id"
    t.index ["league_id"], name: "index_exchange_leagues_on_league_id"
  end

  create_table "exchanges", force: :cascade do |t|
    t.string "name", null: false
    t.string "status", default: "online", null: false
    t.decimal "maker_fee", default: "0.0", null: false
    t.decimal "taker_fee", default: "0.0", null: false
    t.decimal "withdrawal_fee", default: "0.0", null: false
    t.decimal "deposit_fee", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fistfights", force: :cascade do |t|
    t.bigint "league_id", null: false
    t.bigint "attacker_id", null: false
    t.bigint "defender_id", null: false
    t.integer "round", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attacker_id"], name: "index_fistfights_on_attacker_id"
    t.index ["defender_id", "attacker_id"], name: "index_fistfights_on_defender_id_and_attacker_id", unique: true
    t.index ["defender_id"], name: "index_fistfights_on_defender_id"
    t.index ["league_id"], name: "index_fistfights_on_league_id"
    t.index ["round", "attacker_id"], name: "index_fistfights_on_round_and_attacker_id", unique: true
    t.index ["round", "defender_id"], name: "index_fistfights_on_round_and_defender_id", unique: true
  end

  create_table "league_invites", force: :cascade do |t|
    t.bigint "league_id", null: false
    t.bigint "receiver_id", null: false
    t.bigint "sender_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id", "receiver_id"], name: "index_league_invites_on_league_id_and_receiver_id", unique: true
    t.index ["league_id"], name: "index_league_invites_on_league_id"
    t.index ["receiver_id"], name: "index_league_invites_on_receiver_id"
    t.index ["sender_id"], name: "index_league_invites_on_sender_id"
  end

  create_table "league_users", force: :cascade do |t|
    t.bigint "league_id", null: false
    t.bigint "user_id", null: false
    t.boolean "ready", default: false, null: false
    t.boolean "set_up", default: false, null: false
    t.string "status", default: "alive", null: false
    t.integer "rank", default: 0, null: false
    t.decimal "btce", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id", "user_id"], name: "index_league_users_on_league_id_and_user_id", unique: true
    t.index ["league_id"], name: "index_league_users_on_league_id"
    t.index ["user_id"], name: "index_league_users_on_user_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name", null: false
    t.string "entry_fee", default: "FREE", null: false
    t.string "prize", default: "Bragging Rights", null: false
    t.decimal "starting_balance", default: "1.0", null: false
    t.string "starting_exchange", default: "any", null: false
    t.boolean "balance_revivable", default: false, null: false
    t.boolean "exchange_fees", default: true, null: false
    t.boolean "exchange_risk", default: true, null: false
    t.bigint "commissioner_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.integer "rounds", default: 1, null: false
    t.integer "round", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commissioner_id"], name: "index_leagues_on_commissioner_id"
  end

  create_table "leverages", force: :cascade do |t|
    t.string "kind", null: false
    t.decimal "size", null: false
    t.decimal "liquidation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "base_currency_id", null: false
    t.bigint "quote_currency_id", null: false
    t.boolean "open", default: true, null: false
    t.decimal "size", null: false
    t.decimal "reserve_size", default: "0.0", null: false
    t.decimal "price", null: false
    t.decimal "fee", default: "0.0", null: false
    t.string "product", null: false
    t.string "side", default: "buy", null: false
    t.string "kind", default: "market", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_currency_id", "quote_currency_id", "id"], name: "index_orders_on_base_currency_id_and_quote_currency_id_and_id", unique: true
    t.index ["base_currency_id"], name: "index_orders_on_base_currency_id"
    t.index ["quote_currency_id"], name: "index_orders_on_quote_currency_id"
  end

  create_table "tickers", force: :cascade do |t|
    t.bigint "exchange_id", null: false
    t.decimal "price", default: "0.0", null: false
    t.string "pair", null: false
    t.string "natural_pair", null: false
    t.string "base_currency", null: false
    t.string "quote_currency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_id"], name: "index_tickers_on_exchange_id"
    t.index ["pair", "exchange_id"], name: "index_tickers_on_pair_and_exchange_id", unique: true
  end

  create_table "transaction_histories", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.boolean "completed", default: true, null: false
    t.decimal "amount", null: false
    t.decimal "fee", default: "0.0", null: false
    t.string "address", null: false
    t.string "coin", null: false
    t.boolean "deposit_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id"], name: "index_transaction_histories_on_wallet_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "admin", default: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.string "coin_type", null: false
    t.decimal "total_quantity", precision: 1000, scale: 8, default: "0.0", null: false
    t.decimal "reserve_quantity", precision: 1000, scale: 8, default: "0.0", null: false
    t.string "public_key", null: false
    t.bigint "league_user_id"
    t.bigint "exchange_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coin_type", "exchange_id", "league_user_id"], name: "unique_wallet", unique: true
    t.index ["exchange_id"], name: "index_wallets_on_exchange_id"
    t.index ["league_user_id"], name: "index_wallets_on_league_user_id"
    t.index ["public_key"], name: "index_wallets_on_public_key", unique: true
  end

  add_foreign_key "fistfights", "users", column: "attacker_id"
  add_foreign_key "fistfights", "users", column: "defender_id"
  add_foreign_key "league_invites", "users", column: "receiver_id"
  add_foreign_key "league_invites", "users", column: "sender_id"
  add_foreign_key "leagues", "users", column: "commissioner_id"
  add_foreign_key "orders", "wallets", column: "base_currency_id"
  add_foreign_key "orders", "wallets", column: "quote_currency_id"
end
