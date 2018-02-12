require 'test_helper'

class PersistenceFlowsTest < ActionDispatch::IntegrationTest
  def setup
    @player = players('sam')
  end

  test "Remember me after login" do
    get login_path
    assert_response :success
    log_in_as(@player, remember_me: '1', password: '123')
    assert_redirected_to leaderboards_path
    follow_redirect!
    assert_not_nil cookies['remember_token']
  end

  test "Don't remember me after login" do 
    get login_path
    assert_response :success
    log_in_as(@player, remember_me: '0', password: '123')
    assert_redirected_to leaderboards_path
    follow_redirect!
    assert_nil cookies['remember_token']
  end
end
