require 'freshbooks/schema/mixin'

module FreshBooks
  class Base
    include FreshBooks::Schema::Mixin
    
    @@connection = nil
    def self.connection
      @@connection
    end
    
    def self.establish_connection(account_url, auth_token, request_headers = {})
      @@connection = Connection.new(account_url, auth_token, request_headers)
    end
    
    
    MAPPING_FNS = {
      :string => lambda { |xml_val| 
        xml_val.text.to_s
      },
      :fixnum => lambda { |xml_val| 
        xml_val.text.to_i
      },
      :float => lambda { |xml_val|
        xml_val.text.to_f 
      },
      :date => lambda { |xml_val| 
        Date.parse(xml_val.text.to_s) 
      },
      :object => lambda { |xml_val| 
        FreshBooks::const_get(xml_val.name.camelize)::new_from_xml(xml_val) 
      },
      :array  => lambda { |xml_val|
        xml_val.elements.map { |elem|
          FreshBooks::const_get(elem.name.camelize)::new_from_xml(elem)
        }
      }
    }
    
    def self.new_from_xml(xml_root)
      object = self.new
      
      self.schema_definition.members.each do |member_name, member_options|
        node = xml_root.elements[member_name]
        next if node.nil?
        
        member_type = member_options[:type]
        mapping_lambda = self::MAPPING_FNS[member_type]
        raise "No mapping type #{member_type} defined." if mapping_lambda.nil?
        
        object.send("#{member_name}=", mapping_lambda.call(node))
      end
      
      return object
    end
    
    def to_xml(elem_name = nil)
      # The root element is the class name underscored
      elem_name ||= self.class.to_s.split('::').last.underscore
      root = Element.new(elem_name)
      
      # Add each BaseObject member to the root elem
      self.schema_definition.members.each do |member_name, member_options|
        next if member_options[:read_only]
        
        value = self.send(member_name)
        
        if value.kind_of?(Array)
          node = root.add_element(member_name)
          value.each { |array_elem|
            node.add_element(Document.new(array_elem.to_xml))
          }
        elsif value.kind_of?(FreshBooks::Base)
          root.add_element(Document.new(value.to_xml(member_name)))
        elsif !value.nil?
          root.add_element(member_name).text = value
        end
      end
      
      root.to_s
    end
    
    def self.build_list_with_pagination(response)
      root = response.elements[1]
      objects = root.elements
      objects = objects.map { |object| self.new_from_xml(object) }
      
      page = root.attributes["page"]
      pages = root.attributes["pages"]
      per_page = root.attributes["per_page"]
      total = root.attributes["total"]
      
      ListProxy.new(objects, page, per_page, pages, total)
    end
  end
end
