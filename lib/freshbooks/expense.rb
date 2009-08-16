module FreshBooks
  class Expense < FreshBooks::Base
    define_schema do |s|
      s.fixnum :expense_id, :staff_id, :category_id, :project_id, :client_id
      s.float :amount, :tax1_amount, :tax1_percent, :tax2_amount, :tax2_percent
      s.date :date
      s.string :notes, :vendor, :status, :tax1_name, :tax2_name
    end
    
    actions :list, :get, :create, :update, :delete
  end
end
