module FreshBooks
  class Recurring < FreshBooks::Base
    define_schema do |s|
      s.string :first_name, :last_name, :organization, :p_street1, :p_street2, :p_city
      s.string :p_state, :p_country, :p_code, :lines, :notes, :terms, :frequency
      s.date :date
      s.fixnum :recurring_id, :client_id, :po_number, :occurrences
      s.float :discount, :amount
      s.array :lines
      s.boolean :stopped, :send_email, :send_snail_mail
      s.string :return_uri
    end
    
    actions :list, :get, :create, :update, :delete
  end
end