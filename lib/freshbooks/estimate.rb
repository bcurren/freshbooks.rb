module FreshBooks
  Estimate = BaseObject.new(:estimate_id, :client_id, :status, :date, :po_number, :discount, :notes,
    :terms, :first_name, :last_name, :organization, :p_street1, :p_street2, :p_city, :p_state, :p_country,
    :p_code, :lines)


  class Estimate
    TYPE_MAPPINGS = { 'client_id' => Fixnum, 'lines' => Array, 
    'po_number' => Fixnum, 'discount' => Float, 'amount' => Float }

    def initialize
      super
      self.lines ||= []
    end

    def create
      resp = FreshBooks::call_api('estimate.create', 'invoice' => self)
      if resp.success?
        self.invoice_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.invoice_id : nil
    end

    def update
      resp = FreshBooks::call_api('estimate.update', 'estimate' => self)

      resp.success?
    end

    def delete; Estimate::delete(self.estimate_id); end;
    def send_by_email; Estimate::send_by_email(self.estimate_id); end;
  
    def self.get(estimate_id)
      resp = FreshBooks::call_api('estimate.get', 'estimate_id' => estimate_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.delete(estimate_id)
      resp = FreshBooks::call_api('estimate.delete', 'estimate_id' => estimate_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('estimate.list', options)
    
      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end

    def self.send_by_email(estimate_id)
      resp = FreshBooks::call_api('estimate.sendByEmail', 'estimate_id' => estimate_id)

      resp.success?
    end
  end
end
