require 'test_helper'

class PlayersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @player = players('sam')
  end


  test "login with invalid information" do 
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "1238"} } 
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information" do 
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "sam@gmail.com", 
                                          password: "123"} }
    assert_redirected_to leaderboards_path
    follow_redirect! 
    assert_template 'players/index'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
  end
end
