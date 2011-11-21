module FreshBooks
  class Language < FreshBooks::Base
    define_schema do |s|
      s.string :code, :name
    end
    
    actions :list
  end
end
