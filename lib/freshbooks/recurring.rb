module FreshBooks
  
  Recurring = BaseObject.new(:recurring_id, :client_id, :date, :po_number,
  :terms, :first_name, :last_name, :organization, :p_street1, :p_street2, :p_city,
  :p_state, :p_country, :p_code, :amount, :lines, :discount, :status, :notes,
  :occurrences, :frequency, :send_email, :send_snail_mail)


  class Recurring
    TYPE_MAPPINGS = { 'client_id' => Fixnum, 'lines' => Array,
      'po_number' => Fixnum, 'discount' => Float, 'amount' => Float,
      'occurrences' => Fixnum }

    def initialize
      super
      self.lines ||= []
    end

    def create
      resp = FreshBooks::call_api('recurring.create', 'recurring' => self)
      if resp.success?
        self.invoice_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.invoice_id : nil
    end

    def update
      resp = FreshBooks::call_api('recurring.update', 'recurring' => self)

      resp.success?
    end

    def self.get(recurring_id)
      resp = FreshBooks::call_api('recurring.get', 'recurring_id' => recurring_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def delete
      Recurring::delete(self.recurring_id)
    end

    def self.delete(recurring_id)
      resp = FreshBooks::call_api('recurring.delete', 'recurring_id' => recurring_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('recurring.list', options)

      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end

  end
end