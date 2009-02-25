require 'freshbooks/connection'

class MockConnection < FreshBooks::Connection
  def initialize(response_body)
    @response_body = response_body
  end
  
protected
  
  def post(request_body)
    @response_body
  end
end
