require 'test_helper'

class PlayersSignupTest < ActionDispatch::IntegrationTest
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'Player.count' do 
      post players_path, params: { player:  { username:              "",
                                              email:                 "em",
                                              password:              "111",
                                              password_confirmation: "123"} }
    end
    assert_template 'players/new'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'Player.count', 1 do
      post players_path, params: { player:  { username:              "Vaild",
                                              email:             "v@gmail.com",
                                              password:              "123",
                                              password_confirmation: "123"} }
    end
    follow_redirect!
    assert_template 'players/index'
  end
end
