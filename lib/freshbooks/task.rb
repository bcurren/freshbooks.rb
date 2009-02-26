module FreshBooks
  class Task < FreshBooks::Base
    define_schema do |s|
      s.fixnum :task_id
      s.string :name, :description
      s.float :rate
      s.boolean :billable
    end
    
    actions :list, :get, :create, :update, :delete
  end
end
