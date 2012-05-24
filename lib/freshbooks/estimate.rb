module FreshBooks
  class Estimate < FreshBooks::Base
    define_schema do |s|
      s.string :estimate_id, :status, :date, :notes, :terms, :first_name, :number
      s.string :last_name, :organization, :p_street1, :p_street2, :p_city
      s.string :p_state, :p_country, :p_code, :currency_code, :language
      s.fixnum :client_id, :po_number, :staff_id
      s.float :discount, :amount
      s.array :lines
      s.object :links, :read_only => true
    end
    
    actions :list, :get, :create, :update, :delete, :send_by_email
  end
end
