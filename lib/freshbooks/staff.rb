module FreshBooks
  class Staff < FreshBooks::Base
    define_schema do |s|
      s.fixnum :staff_id, :number_of_logins
      s.string :username, :first_name, :last_name, :email, :business_phone, :mobile_phone
      s.string :street1, :street2, :city, :state, :country, :code
      s.float :rate
      s.date_time :last_login, :signup_date
    end
    
    actions :list, :get
    
    def self.current
      response = FreshBooks::Base.connection.call_api("#{api_class_name}.current")
      response.success? ? self.new_from_xml(response.elements[1]) : nil
    end
  end
end
