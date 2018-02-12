require 'test_helper'

class FriendlyForwardingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @player = players(:sam)
  end

  test "Redirect to stored location after permission fail/pass loop." do
    get "/players/#{@player.id}/edit"
    assert_redirected_to login_path
    follow_redirect!
    log_in_as(@player, password: '123', remember_me: '0')
    assert_redirected_to "/players/#{@player.id}/edit"
  end
end
