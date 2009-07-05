require File.dirname(__FILE__) + '/test_helper.rb'

class TestConnection < Test::Unit::TestCase
  def setup
    @connection = FreshBooks::Connection.new("company.freshbooks.com", "auth_token")
  end
  
  def test_connection_accessors
    assert_equal "company.freshbooks.com", @connection.account_url
    assert_equal "auth_token", @connection.auth_token
  end
  
  def test_connection_request_headers
    request_headers = { "key" => "value" }
    connection = FreshBooks::Connection.new("company.freshbooks.com", "auth_token", request_headers)
    assert_equal request_headers, connection.request_headers
  end
  
  
  def test_create_request__array_of_elements
    request = @connection.send(:create_request, 'mymethod', [['element1', 'value1'], [:element2, :value2]])
    assert_equal "<?xml version='1.0' encoding='UTF-8'?><request method='mymethod'><element1>value1</element1><element2>value2</element2></request>", request
  end
  
  def test_create_request__base_object_element
    invoice = FreshBooks::Invoice.new
    invoice.expects(:to_xml).with().returns("<invoice><number>23</number></invoice>")
    
    request = @connection.send(:create_request, 'mymethod', 'invoice' => invoice)
    assert_equal "<?xml version='1.0' encoding='UTF-8'?><request method='mymethod'><invoice><number>23</number></invoice></request>", request
  end
  
  def test_check_for_api_error__success
    body = "body xml"
    response = Net::HTTPSuccess.new("1.1", "200", "message")
    response.expects(:body).with().returns(body)
    assert_equal body, @connection.send(:check_for_api_error, response)
  end
  
  def test_check_for_api_error__unknown_system
    response = Net::HTTPMovedPermanently.new("1.1", "301", "message")
    response.stubs(:[]).with("location").returns("loginSearch")
    assert_raise(FreshBooks::UnknownSystemError) do
      @connection.send(:check_for_api_error, response)
    end
  end
  
  def test_check_for_api_error__deactivated
    response = Net::HTTPMovedPermanently.new("1.1", "301", "message")
    response.stubs(:[]).with("location").returns("deactivated")
    assert_raise(FreshBooks::AccountDeactivatedError) do
      @connection.send(:check_for_api_error, response)
    end
  end
  
  def test_check_for_api_error__unauthorized
    response = Net::HTTPUnauthorized.new("1.1", "401", "message")
    assert_raise(FreshBooks::AuthenticationError) do
      @connection.send(:check_for_api_error, response)
    end
  end
  
  def test_check_for_api_error__bad_request
    response = Net::HTTPBadRequest.new("1.1", "401", "message")
    assert_raise(FreshBooks::ApiAccessNotEnabledError) do
      @connection.send(:check_for_api_error, response)
    end
  end
  
  def test_check_for_api_error__internal_error
    response = Net::HTTPBadGateway.new("1.1", "502", "message")
    assert_raise(FreshBooks::InternalError) do
      @connection.send(:check_for_api_error, response)
    end
    
    response = Net::HTTPMovedPermanently.new("1.1", "301", "message")
    response.stubs(:[]).with("location").returns("somePage")
    assert_raise(FreshBooks::InternalError) do
      @connection.send(:check_for_api_error, response)
    end
  end
  
  def test_close_is_only_called_once_in_ntexted_start_sessions
    @connection.expects(:obtain_connection)
    @connection.expects(:close)
    
    @connection.start_session { @connection.start_session { } }
  end

end