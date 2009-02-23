module FreshBooks
  Expense = BaseObject.new(:expense_id, :staff_id, :category_id, :project_id, :client_id,
    :amount, :date, :notes, :status, :tax1_name, :tax1_percent, :tax1_amount, :tax2_name, 
    :tax2_percent, :tax2_amount)
    
  class Expense
    TYPE_MAPPINGS = { 
      'expense_id' => Fixnum, 
      'staff_id' => Fixnum,
      'category_id' => Fixnum,
      'project_id' => Fixnum,
      'client_id' => Fixnum, 
      'amount' => Float,
      'tax1_amount' => Float,
      'tax1_percent' => Float,
      'tax2_amount' => Float,
      'tax2_percent' => Float }

    def create
      resp = FreshBooks::call_api('exp.create', 'expense' => self)
      if resp.success?
        self.expense_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.expense_id : nil
    end

    def update
      resp = FreshBooks::call_api('expense.update', 'expense' => self)

      resp.success?
    end

    def delete
      expense::delete(self.expense_id)
    end
    
    def self.get(expense_id)
      resp = FreshBooks::call_api('expense.get', 'expense_id' => expense_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.delete(expense_id)
      resp = FreshBooks::call_api('expense.delete', 'expense_id' => expense_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('expense.list', options)
      
      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end
  end
end