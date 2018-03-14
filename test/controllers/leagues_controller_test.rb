require 'test_helper'

class LeaguesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @league = leagues(:one)
  end

  test "should get index" do
    get leagues_url
    assert_response :success
  end

  test "should get new" do
    get new_league_url
    assert_response :success
  end

  test "should create league" do
    assert_difference('League.count') do
      post leagues_url, params: { league: { commissioner: @league.commissioner, end_date: @league.end_date, entry_fee: @league.entry_fee, exchange_fees: @league.exchange_fees, exchange_risk: @league.exchange_risk, high_be_score: @league.high_be_score, instant_deposits_withdraws: @league.instant_deposits_withdraws, lazy_picker: @league.lazy_picker, name: @league.name, public_keys: @league.public_keys, rounds: @league.rounds, start_date: @league.start_date } }
    end

    assert_redirected_to league_url(League.last)
  end

  test "should show league" do
    get league_url(@league)
    assert_response :success
  end

  test "should get edit" do
    get edit_league_url(@league)
    assert_response :success
  end

  test "should update league" do
    patch league_url(@league), params: { league: { commissioner: @league.commissioner, end_date: @league.end_date, entry_fee: @league.entry_fee, exchange_fees: @league.exchange_fees, exchange_risk: @league.exchange_risk, high_be_score: @league.high_be_score, instant_deposits_withdraws: @league.instant_deposits_withdraws, lazy_picker: @league.lazy_picker, name: @league.name, public_keys: @league.public_keys, rounds: @league.rounds, start_date: @league.start_date } }
    assert_redirected_to league_url(@league)
  end

  test "should destroy league" do
    assert_difference('League.count', -1) do
      delete league_url(@league)
    end

    assert_redirected_to leagues_url
  end
end
