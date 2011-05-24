module FreshBooks
  class Expiration < FreshBooks::Base

    define_schema do |s|
      s.string :month, :year
    end
  end
end