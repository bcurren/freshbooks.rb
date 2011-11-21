module FreshBooks
  class Gateway < FreshBooks::Base
    define_schema do |s|
      s.string :name
      s.boolean :autobill_capable
    end
    
    actions :list
  end
end
