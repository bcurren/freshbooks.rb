require 'freshbooks/base_object'

module FreshBooks
  class Invoice < FreshBooks::Base
    define_schema do |s|
      s.fixnum :invoice_id, :client_id, :recurring_id, :po_number
      s.float :amount, :amount_outstanding, :discount
      s.date :date
      s.array :lines
      s.object :links
      s.string :number, :organization, :status, :notes, :terms, :first_name, :last_name
      s.string :p_street1, :p_street2, :p_city, :p_state, :p_country, :p_code
    end
    
    def self.define_class_method(symbol, &block)
      self.class.send(:define_method, symbol, &block)
    end
    
    def self.actions(*operations)
      operations.each do |operation|
        method_name = operation.to_s
        api_action_name = method_name.camelize(:lower)
        
        case method_name
        when "list"
          define_class_method(method_name) do |*args|
            options = args.any? ? args.first : {}
            api_list_action(api_action_name, options)
          end
        when "get"
          define_class_method(method_name) do |object_id|
            api_get_action(api_action_name, object_id)
          end
        when "create"
          define_method(method_name) do
            api_create_action(api_action_name)
          end
        when "update"
          define_method(method_name) do
            api_update_action(api_action_name)
          end
        else
          define_method(method_name) do
            api_action(api_action_name)
          end
        end
      end
    end
    
    actions :list, :get, :create, :update, :delete, :send_by_email, :send_by_snail_mail
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