module FreshBooks
  class Contact < FreshBooks::Base
    define_schema do |s|
      s.string :email, :username, :first_name, :last_name, :phone1, :phone2
    end
    
    actions :list, :get, :create, :update, :delete
  end
end
