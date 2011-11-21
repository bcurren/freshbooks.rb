module FreshBooks
  class Budget < FreshBooks::Base
    define_schema do |s|
      s.float :hours
    end
  end
end