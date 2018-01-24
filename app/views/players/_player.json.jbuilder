json.extract! player, :id, :username, :cash, :bitcoin, :rank, :email, :created_at, :updated_at
json.url player_url(player, format: :json)
