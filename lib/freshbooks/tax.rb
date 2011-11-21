module FreshBooks
  class Tax < FreshBooks::Base
    define_schema do |s|
      s.fixnum :tax_id
      s.float :rate
      s.boolean :compound
      s.string :name, :number
    end
    
    actions :list, :get, :create, :update, :delete
  end
end
