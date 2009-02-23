module FreshBooks
  Client = BaseObject.new(:client_id, :first_name, :last_name, :organization,
    :email, :username, :password, :work_phone, :home_phone, :mobile, :fax,
    :notes, :p_street1, :p_street2, :p_city, :p_state, :p_country, :p_code,
    :s_street1, :s_street2, :s_city, :s_state, :s_country, :s_code, :url, :auth_url)

  class Client
    TYPE_MAPPINGS = { 'client_id' => Fixnum }
    MUTABILITY = { :url => :read_only }
    def create
      resp = FreshBooks::call_api('client.create', 'client' => self)
      if resp.success?
        self.client_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.client_id : nil
    end

    def update
      resp = FreshBooks::call_api('client.update', 'client' => self)

      resp.success?
    end

    def delete
      Client::delete(self.client_id)
    end

    def self.get(client_id)
      resp = FreshBooks::call_api('client.get', 'client_id' => client_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('client.list', options)
      
      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end

    def self.delete(client_id)
      resp = FreshBooks::call_api('client.delete', 'client_id' => client_id)

      resp.success?
    end

    def invoices(options = {})
      options.merge( 'client_id' => self.client_id )

      Invoice::list(options)
    end
  end
end