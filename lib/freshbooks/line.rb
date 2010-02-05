module FreshBooks
  class Line < FreshBooks::Base
    
    define_schema do |s|
      s.string :name, :description, :tax1_name, :tax2_name
      s.float :unit_cost, :tax1_percent, :tax2_percent
      s.float :amount, :read_only => true
      s.float :quantity
    end
  end
end