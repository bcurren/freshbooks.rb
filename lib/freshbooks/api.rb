module FreshBooks
  class Api < FreshBooks::Base
    define_schema do |s|
      s.fixnum :requests, :request_limit
    end
  end
end
