module FreshBooks
  class System < FreshBooks::Base
    define_schema do |s|
      s.string :company_name, :profession
      s.object :address
      s.object :api
    end
    
    def self.current
      response = FreshBooks::Base.connection.call_api("#{api_class_name}.current")
      response.success? ? self.new_from_xml(response.elements[1]) : nil
    end
  end
end
