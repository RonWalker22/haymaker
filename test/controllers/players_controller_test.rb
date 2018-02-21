require 'test_helper'

class PlayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @player = players(:sam)
  end

  test "should get index" do
    get players_url
    assert_response :success
  end

  test "should get new player" do
    get new_player_url
    assert_response :success
  end

  test "should create player" do
    assert_difference('Player.count') do
      post players_url, params: { player: { bitcoin: @player.bitcoin, 
                                            cash: @player.cash, 
                                            email: @player.email, 
                                            rank: @player.rank, 
                                            username: @player.username,
                                            password: '123',
                                            password_confirmation: '123' } }
    end

    assert_redirected_to leaderboards_path
  end

  test "should show player" do
    get player_url(@player)
    assert_response :success
  end

  test "should get edit" do
    post login_path, params: { session: { email: "sam@gmail.com", 
                                          password: "123"} }
    get edit_player_url(@player)
    assert_response :success
  end

  test "should update player" do
    post login_path, params: { session: { email: "sam@gmail.com", 
                                          password: "123"} }
    patch player_url(@player), params: { player: { bitcoin: @player.bitcoin, cash: @player.cash, email: @player.email, rank: @player.rank, username: @player.username } }
    assert_redirected_to player_path(@player)
    follow_redirect!
    assert_response :success
  end

  test "should destroy player" do
    post login_path, params: { session: { email: "sam@gmail.com", 
                                          password: "123"} }
    assert_difference('Player.count', -1) do
      delete player_url(@player)
    end

    assert_redirected_to players_url
  end
end
