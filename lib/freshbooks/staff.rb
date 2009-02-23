module FreshBooks
  Staff = BaseObject.new(:staff_id, :username, :first_name, :last_name, 
    :email,  :business_phone, :mobile_phone, :rate, :last_login,
    :number_of_logins, :signup_date, 
    :street1, :street2, :city, :state, :country, :code)

  class Staff
    TYPE_MAPPINGS = { 'staff_id' => Fixnum }

    def self.get(staff_id)
      resp = FreshBooks::call_api('staff.get', 'staff_id' => staff_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('staff.list', options)

      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end
  end
end
