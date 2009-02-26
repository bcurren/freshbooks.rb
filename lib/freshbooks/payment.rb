module FreshBooks
  class Payment < FreshBooks::Base
    define_schema do |s|
      s.fixnum :client_id, :invoice_id, :payment_id
      s.float :amount
      s.date :date
      s.string :type, :notes
    end
    
    actions :list, :get, :create, :update
  end
end
