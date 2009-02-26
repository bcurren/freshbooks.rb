module FreshBooks
  class Category < FreshBooks::Base
    define_schema do |s|
      s.fixnum :category_id
      s.float :tax1, :tax2
      s.string :name
    end
    
    actions :list, :get, :create, :update, :delete
  end
end
