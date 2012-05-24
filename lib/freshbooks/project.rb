module FreshBooks
  class Project < FreshBooks::Base
    define_schema do |s|
      s.string :name, :bill_method, :description
      s.fixnum :project_id, :client_id
      s.float :rate, :hour_budget
      s.array :tasks
      s.array :staff
      s.object :budget
    end
    
    actions :list, :get, :create, :update, :delete
  end
end