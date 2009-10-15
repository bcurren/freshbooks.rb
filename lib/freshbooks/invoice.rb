module FreshBooks
  class Invoice < FreshBooks::Base
    define_schema do |s|
      s.fixnum :invoice_id, :client_id, :po_number
      s.fixnum :recurring_id, :read_only => true
      s.float :amount, :discount
      s.float :amount_outstanding, :paid, :read_only => true
      s.date :date
      s.date_time :updated
      s.array :lines
      s.object :links, :read_only => true
      s.string :number, :organization, :status, :notes, :terms, :first_name, :last_name
      s.string :p_street1, :p_street2, :p_city, :p_state, :p_country, :p_code
      s.string :return_uri
    end
    
    actions :list, :get, :create, :update, :delete, :send_by_email, :send_by_snail_mail
  end
end