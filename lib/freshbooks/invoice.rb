module FreshBooks
  class Invoice < FreshBooks::Base
    define_schema do |s|
      s.fixnum :invoice_id, :client_id, :po_number
      s.fixnum :recurring_id, :read_only => true
      s.float :amount, :amount_outstanding, :discount, :paid
      s.date :date
      s.array :lines
      s.object :links, :read_only => true
      s.string :number, :organization, :status, :notes, :terms, :first_name, :last_name
      s.string :p_street1, :p_street2, :p_city, :p_state, :p_country, :p_code
    end
    
    actions :list, :get, :create, :update, :delete, :send_by_email, :send_by_snail_mail
  end
end