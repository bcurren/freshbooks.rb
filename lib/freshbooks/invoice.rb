require 'freshbooks/base_object'

module FreshBooks
  Invoice = BaseObject.new(
    :invoice_id, :number, :client_id, :recurring_id, :organization, :status,
    :amount, :amount_outstanding, :date,
    
    :po_number, :discount, :notes, :terms,
    
    :first_name, :last_name, :p_street1, :p_street2, :p_city, :p_state,
    :p_country, :p_code,
    
    :lines, :links)
  
  class Invoice
    TYPE_MAPPINGS = {
      "invoice_id" => Fixnum,
      'client_id' => Fixnum,
      'recurring_id' => Fixnum,
      'amount' => Float,
      'amount_outstanding' => Float,
      'date' => Date,
      'po_number' => Fixnum,
      'discount' => Float,
      'lines' => Array,
      'links' => BaseObject
    }
    
    MUTABILITY = { 
      :url => :read_only,
      :auth_url => :read_only
    }
    
    
    
    
    
    def self.api_class_name
      # Remove module, underscore between words, lowercase
      self.name.
        gsub(/^.*::/, "").
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        downcase
    end
    
    def self.api_list_action(action_name, options = {})
      response = FreshBooks::Base.connection.call_api("#{api_class_name}.#{action_name}", options)
      self.build_list_with_pagination(response) if response.success?
    end
    
    def self.api_get_action(action_name, object_id)
      response = FreshBooks::Base.connection.call_api(
        "#{api_class_name}.#{action_name}",
        "#{api_class_name}_id" => object_id)
      response.success? ? self.new_from_xml(response.elements[1]) : nil
    end
    
    def self.api_action(action_name, object_id)
      response = FreshBooks::Base.connection.call_api(
        "#{api_class_name}.#{action_name}", 
        "#{api_class_name}_id" => object_id)
      response.success?
    end
    
    
    
    
    
    
    def initialize
      super
      self.lines ||= []
    end
    
    def self.list(options = {})
      self.api_list_action("list", options)
    end
    
    def self.get(object_id)
      self.api_get_action("get", object_id)
    end
    
    def self.delete(object_id)
      self.api_action("delete", object_id)
    end
    
    def self.send_by_email(object_id)
      self.api_action("sendByEmail", object_id)
    end

    def self.send_by_snail_mail(object_id)
      self.api_action("sendBySnailMail", object_id)
    end
    
    def create
      response = FreshBooks::Base.connection.call_api('invoice.create', 'invoice' => self)
      self.invoice_id = response.elements[1].text.to_i if response.success?
      response.success?
    end
    
    def update
      response = FreshBooks::Base.connection.call_api('invoice.update', 'invoice' => self)
      response.success?
    end
    
    def delete
      self.class.delete(self.invoice_id)
    end
    
    def send_by_email
      self.class.send_by_email(self.invoice_id) 
    end
    
    def send_by_snail_mail
      self.class.send_by_snail_mail(self.invoice_id)
    end
  end
  
  Links = BaseObject.new(:client_view, :view, :edit)
  class Links
    MUTABILITY = { 
      :client_view => :read_only,
      :view => :read_only,
      :edit => :read_only
    }
  end
  
  Line = BaseObject.new(:name, :description, :unit_cost, :quantity, :tax1_name,
    :tax2_name, :tax1_percent, :tax2_percent, :amount)
  class Line
    TYPE_MAPPINGS = {
      'unit_cost' => Float,
      'quantity' => Fixnum,
      'tax1_percent' => Float,
      'tax2_percent' => Float,
      'amount' => Float 
    }
  end
  
  Item = BaseObject.new(:item_id, :name, :description, :unit_cost, :quantity, 
    :inventory)
  class Item
    TYPE_MAPPINGS = {
      'item_id' => Fixnum, 
      'unit_cost' => Float,
      'quantity' => Fixnum,
      'inventory' => Fixnum 
    }
    
    def create
      resp = FreshBooks::Base.connection.call_api('item.create', 'item' => self)
      if resp.success?
        self.item_id = resp.elements[1].text.to_i
      end
      
      resp.success? ? self.item_id : nil
    end
    
    def update
      resp = FreshBooks::Base.connection.call_api('item.update', 'item' => self)
      resp.success?
    end
    
    def delete
      Item::delete(self.item_id)
    end
    
    def self.get(item_id)
      resp = FreshBooks::Base.connection.call_api('item.get', 'item_id' => item_id)
      
      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end
    
    def self.delete(item_id)
      resp = FreshBooks::Base.connection.call_api('item.delete', 'item_id' => item_id)
      resp.success?
    end
    
    def self.list(options = {})
      resp = FreshBooks::Base.connection.call_api('item.list', options)
      
      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end
  end
end