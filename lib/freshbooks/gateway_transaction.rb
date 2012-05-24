module FreshBooks
  class GatewayTransaction < FreshBooks::Base
    define_schema do |s|
      s.fixnum :reference_id
      s.string :gateway_name
    end
  end
end
