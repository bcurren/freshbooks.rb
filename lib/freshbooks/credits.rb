module FreshBooks
  class Credits < FreshBooks::Base
    define_schema do |s|
      s.string :credit, :currency, :read_only => true
    end
  end
end