module FreshBooks
  class Estimate < FreshBooks::Base
    define_schema do |s|
      s.string :estimate_id, :status, :date, :notes, :terms, :first_name
      s.string :last_name, :organization, :p_street1, :p_street2, :p_city
      s.string :p_state, :p_country, :p_code
      s.fixnum :client_id, :po_number
      s.float :discount, :amount
      s.array :lines
      s.object :links, :read_only => true
    end
    
    actions :list, :get, :create, :update, :delete, :send_by_email
  end
end
