module FreshBooks
  Payment = BaseObject.new(:payment_id, :client_id, :invoice_id, :date, :amount, :type, :notes)
  class Payment
    TYPE_MAPPINGS = { 'client_id' => Fixnum, 'invoice_id' => Fixnum, 'amount' => Float }

    def create
      resp = FreshBooks::call_api('payment.create', 'payment' => self)
      if resp.success?
        self.payment_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.payment_id : nil
    end

    def update
      resp = FreshBooks::call_api('payment.update', 'payment' => self)

      resp.success?
    end

    def self.get(payment_id)
      resp = FreshBooks::call_api('payment.get', 'payment_id' => payment_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('payment.list', options)

      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end
  end
end