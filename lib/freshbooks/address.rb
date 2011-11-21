module FreshBooks
  class Address < FreshBooks::Base
    define_schema do |s|
      s.string :street1, :street2, :city, :state, :country, :code
    end
  end
end
