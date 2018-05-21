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

ActiveRecord::Schema.define(version: 20180430162531) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exchange_leagues", force: :cascade do |t|
    t.bigint "exchange_id"
    t.bigint "league_id"
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

  create_table "league_users", force: :cascade do |t|
    t.bigint "league_id"
    t.bigint "user_id"
    t.boolean "ready", default: false, null: false
    t.boolean "set_up", default: false, null: false
    t.string "status", default: "alive", null: false
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
    t.bigint "user_id"
    t.datetime "start_date", default: "2018-05-21 23:19:14", null: false
    t.datetime "end_date", default: "2018-06-21 23:19:14", null: false
    t.integer "rounds", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_leagues_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.boolean "open", default: true, null: false
    t.decimal "size", null: false
    t.decimal "price", null: false
    t.decimal "fee", default: "0.0", null: false
    t.string "product", null: false
    t.boolean "buy", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id"], name: "index_orders_on_wallet_id"
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
    t.decimal "coin_quantity", default: "0.0", null: false
    t.string "public_key", null: false
    t.bigint "user_id"
    t.bigint "exchange_id"
    t.bigint "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coin_type", "user_id", "exchange_id", "league_id"], name: "unique_wallet", unique: true
    t.index ["exchange_id"], name: "index_wallets_on_exchange_id"
    t.index ["league_id"], name: "index_wallets_on_league_id"
    t.index ["public_key"], name: "index_wallets_on_public_key", unique: true
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

end
