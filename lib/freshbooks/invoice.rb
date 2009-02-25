require 'freshbooks/base_object'

module FreshBooks
  class Invoice < FreshBooks::Base
    define_schema do |s|
      s.fixnum :invoice_id, :client_id, :po_number
      s.fixnum :recurring_id, :read_only => true
      s.float :amount, :amount_outstanding, :discount
      s.date :date
      s.array :lines
      s.object :links, :read_only => true
      s.string :number, :organization, :status, :notes, :terms, :first_name, :last_name
      s.string :p_street1, :p_street2, :p_city, :p_state, :p_country, :p_code
    end
    
    actions :list, :get, :create, :update, :delete, :send_by_email, :send_by_snail_mail
  end
  
  class Links < FreshBooks::Base
    define_schema do |s|
      s.string :client_view, :view, :edit, :read_only => true
    end
  end
  
  class Line < FreshBooks::Base
    define_schema do |s|
      s.string :name, :description, :tax1_name, :tax2_name
      s.float :unit_cost, :tax1_percent, :tax2_percent
      s.float :amount, :read_only => true
      s.fixnum :quantity
    end
  end
  
  class Item < FreshBooks::Base
    define_schema do |s|
      s.fixnum :item_id, :quantity, :inventory
      s.float :unit_cost
      s.string :name, :description
    end
    
    actions :create, :update, :get, :delete, :list
  end
end