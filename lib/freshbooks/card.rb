module FreshBooks
  class Card < FreshBooks::Base

    define_schema do |s|
      s.string :number, :name
      s.object :expiration
    end
  end
end