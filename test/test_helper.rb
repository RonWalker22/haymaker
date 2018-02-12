require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def log_in_as(player)
    session[:user_id] = player.id
  end
end

class ActionDispatch::IntegrationTest
  def log_in_as(player, password: '123', remember_me: '1')
    post login_path, params: {session: {email: player.email,
                                        password: password,
                                        remember_me: remember_me } }
  end
end
