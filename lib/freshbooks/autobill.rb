module FreshBooks
  class Autobill < FreshBooks::Base

    define_schema do |s|
      s.string :gateway_name
      s.object :card
    end
  end
end