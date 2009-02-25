module FreshBooks
  class Base
    @@connection = nil
    
    def self.connection
      @@connection
    end
    
    def self.establish_connection(account_url, auth_token, request_headers = {})
      @@connection = Connection.new(account_url, auth_token, request_headers)
    end
  end
end
