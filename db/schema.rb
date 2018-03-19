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

ActiveRecord::Schema.define(version: 20180319010227) do

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

  create_table "league_players", force: :cascade do |t|
    t.bigint "league_id"
    t.bigint "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id", "player_id"], name: "index_league_players_on_league_id_and_player_id", unique: true
    t.index ["league_id"], name: "index_league_players_on_league_id"
    t.index ["player_id"], name: "index_league_players_on_player_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name", null: false
    t.string "entry_fee", default: "free", null: false
    t.bigint "player_id"
    t.string "mode", default: "Fantasy Friendly", null: false
    t.datetime "start_date", default: "2018-03-19 01:08:56", null: false
    t.datetime "end_date", default: "2018-04-19 01:08:56", null: false
    t.integer "rounds", default: 1, null: false
    t.boolean "exchange_risk", default: false, null: false
    t.boolean "exchange_fees", default: false, null: false
    t.boolean "high_be_score", default: true, null: false
    t.boolean "public_keys", default: false, null: false
    t.boolean "instant_deposits_withdraws", default: true, null: false
    t.boolean "lazy_picker", default: false, null: false
    t.boolean "margin_trading", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_leagues_on_player_id"
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

  create_table "players", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.string "password_confirmation"
    t.integer "rank", default: -1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.boolean "admin", default: false
  end

  create_table "wallets", force: :cascade do |t|
    t.string "coin_type", null: false
    t.decimal "coin_quantity", default: "0.0", null: false
    t.string "public_key", null: false
    t.bigint "player_id"
    t.bigint "exchange_id"
    t.bigint "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coin_type", "player_id", "exchange_id", "league_id"], name: "unique_wallet", unique: true
    t.index ["exchange_id"], name: "index_wallets_on_exchange_id"
    t.index ["league_id"], name: "index_wallets_on_league_id"
    t.index ["player_id"], name: "index_wallets_on_player_id"
    t.index ["public_key"], name: "index_wallets_on_public_key", unique: true
  end

end
