require 'freshbooks/schema/mixin'
require 'freshbooks/xml_serializer'

module FreshBooks
  class Base
    include FreshBooks::Schema::Mixin
    
    def initialize(args = {})
      args.each_pair {|k, v| send("#{k}=", v)}
    end
    
    @@connection = nil
    def self.connection
      @@connection
    end
    
    def self.establish_connection(account_url, auth_token, request_headers = {})
      @@connection = Connection.new(account_url, auth_token, request_headers)
    end
    
    def self.new_from_xml(xml_root)
      object = self.new()
      
      self.schema_definition.members.each do |member_name, member_options|
        node = xml_root.elements[member_name.dup]
        next if node.nil?
        
        value = FreshBooks::XmlSerializer.to_value(node, member_options[:type])
        object.send("#{member_name}=", value)
      end
      
      return object
      
    rescue => e
      error = ParseError.new(e, xml_root.to_s)
      error.set_backtrace(e.backtrace)
      raise error
      # raise ParseError.new(e, xml_root.to_s)
    end
    
    def to_xml(elem_name = nil)
      # The root element is the class name underscored
      elem_name ||= self.class.to_s.split('::').last.underscore
      root = REXML::Element.new(elem_name)
      
      # Add each member to the root elem
      self.schema_definition.members.each do |member_name, member_options|
        value = self.send(member_name)
        next if member_options[:read_only] || value.nil?
        
        element = FreshBooks::XmlSerializer.to_node(member_name, value, member_options[:type])
        root.add_element(element) if element != nil
      end
      
      root.to_s
    end
    
    def primary_key
      "#{self.class.api_class_name}_id"
    end
    
    def primary_key_value
      send(primary_key)
    end
    
    def primary_key_value=(value)
      send("#{primary_key}=", value)
    end
    
    def self.api_class_name
      klass = class_of_freshbooks_base_descendant(self)
      
      # Remove module, underscore between words, lowercase
      klass.name.
        gsub(/^.*::/, "").
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        downcase
    end
    
    def self.class_of_freshbooks_base_descendant(klass)
      if klass.superclass == Base
        klass
      elsif klass.superclass.nil?
        raise "#{name} doesn't belong in a hierarchy descending from ActiveRecord"
      else
        self.class_of_freshbooks_base_descendant(klass.superclass)
      end
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
            args << {} if args.empty? # first param is optional and default to empty hash
            api_list_action(api_action_name, *args)
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
    
    def self.api_list_action(action_name, options = {})
      # Create the proc for the list proxy to retrieve the next page
      list_page_proc = proc do |page|
        options["page"] = page
        response = FreshBooks::Base.connection.call_api("#{api_class_name}.#{action_name}", options)
        
        raise FreshBooks::InternalError.new(response.error_msg) unless response.success?
        
        root = response.elements[1]
        array = root.elements.map { |item| self.new_from_xml(item) }
        
        current_page = Page.new(root.attributes['page'], root.attributes['per_page'], root.attributes['total'], array.size)
        
        [array, current_page]
      end
      
      ListProxy.new(list_page_proc)
    end
    
    def self.api_get_action(action_name, object_id)
      response = FreshBooks::Base.connection.call_api(
        "#{api_class_name}.#{action_name}",
        "#{api_class_name}_id" => object_id)
      response.success? ? self.new_from_xml(response.elements[1]) : nil
    end
    
    def api_action(action_name)
      response = FreshBooks::Base.connection.call_api(
        "#{self.class.api_class_name}.#{action_name}", 
        "#{self.class.api_class_name}_id" => primary_key_value)
      response.success?
    end
    
    def api_create_action(action_name)
      response = FreshBooks::Base.connection.call_api(
        "#{self.class.api_class_name}.#{action_name}",
        self.class.api_class_name => self)
      self.primary_key_value = response.elements[1].text.to_i if response.success?
      response.success?
    end
    
    def api_update_action(action_name)
      response = FreshBooks::Base.connection.call_api(
        "#{self.class.api_class_name}.#{action_name}",
        self.class.api_class_name => self)
      response.success?
    end
    
  end
end
