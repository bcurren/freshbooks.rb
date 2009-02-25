require File.dirname(__FILE__) + '/test_helper.rb'

class TestBase < Test::Unit::TestCase
  def test_establish_connection
    assert_nil FreshBooks::Base.connection
    
    FreshBooks::Base.establish_connection("company.freshbooks.com", "auth_token")
    connection = FreshBooks::Base.connection
    assert_not_nil connection
    assert_equal "company.freshbooks.com", connection.account_url
    assert_equal "auth_token", connection.auth_token
    
    FreshBooks::Base.establish_connection("company2.freshbooks.com", "auth_token2")
    connection = FreshBooks::Base.connection
    assert_not_nil connection
    assert_equal "company2.freshbooks.com", connection.account_url
    assert_equal "auth_token2", connection.auth_token
  end
end
