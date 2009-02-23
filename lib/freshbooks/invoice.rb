module FreshBooks
  Invoice = BaseObject.new(:invoice_id, :client_id, :number, :date, :po_number,
  :terms, :first_name, :last_name, :organization, :p_street1, :p_street2, :p_city,
  :p_state, :p_country, :p_code, :amount, :amount_oustanding, :paid,
  :lines, :discount, :status, :notes, :url, :auth_url)


  class Invoice
    TYPE_MAPPINGS = { 'client_id' => Fixnum, 'lines' => Array,
    'po_number' => Fixnum, 'discount' => Float, 'amount' => Float,
    'amount_outstanding' => Float, 'paid' => Float }

    MUTABILITY = { 
      :url => :read_only,
      :auth_url => :read_only 
    }

    def initialize
      super
      self.lines ||= []
    end

    def create
      resp = FreshBooks::call_api('invoice.create', 'invoice' => self)
      if resp.success?
        self.invoice_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.invoice_id : nil
    end

    def update
      resp = FreshBooks::call_api('invoice.update', 'invoice' => self)

      resp.success?
    end

    def delete; Invoice::delete(self.invoice_id); end;
    def send_by_email; Invoice::send_by_email(self.invoice_id); end;
    def send_by_snail_mail; Invoice::send_by_snail_mail(self.invoice_id); end;
    
    def self.get(invoice_id)
      resp = FreshBooks::call_api('invoice.get', 'invoice_id' => invoice_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.delete(invoice_id)
      resp = FreshBooks::call_api('invoice.delete', 'invoice_id' => invoice_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('invoice.list', options)
      
      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end

    def self.send_by_email(invoice_id)
      resp = FreshBooks::call_api('invoice.sendByEmail', 'invoice_id' => invoice_id)

      resp.success?
    end

    def self.send_by_snail_mail(invoice_id)
      resp = FreshBooks::call_api('invoice.sendBySnailMail', 'invoice_id' => invoice_id)

      resp.success?
    end

  end

  Line = BaseObject.new(:name, :description, :unit_cost, :quantity, :tax1_name,
    :tax2_name, :tax1_percent, :tax2_percent, :amount)

  class Line
    TYPE_MAPPINGS = { 'unit_cost' => Float, 'quantity' => Fixnum,
      'tax1_percent' => Float, 'tax2_percent' => Float, 'amount' => Float }
  end

  #--------------------------------------------------------------------------
  # Items
  #==========================================================================

  Item = BaseObject.new(:item_id, :name, :description, :unit_cost,
    :quantity, :inventory)
  class Item
    TYPE_MAPPINGS = { 'item_id' => Fixnum, 'unit_cost' => Float,
      'quantity' => Fixnum, 'inventory' => Fixnum }

    def create
      resp = FreshBooks::call_api('item.create', 'item' => self)
      if resp.success?
        self.item_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.item_id : nil
    end

    def update
      resp = FreshBooks::call_api('item.update', 'item' => self)

      resp.success?
    end

    def delete
      Item::delete(self.item_id)
    end
    
    def self.get(item_id)
      resp = FreshBooks::call_api('item.get', 'item_id' => item_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.delete(item_id)
      resp = FreshBooks::call_api('item.delete', 'item_id' => item_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('item.list', options)
      
      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end
  end
end