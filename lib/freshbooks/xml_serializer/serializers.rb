module FreshBooks
  module XmlSerializer
    class FixnumSerializer
      def self.to_node(member_name, value)
        element = Element.new(member_name)
        element.text = value.to_s
        element
      end
      
      def self.to_value(xml_val)
        xml_val.text.to_i
      end
    end
    
    class FloatSerializer
      def self.to_node(member_name, value)
        element = Element.new(member_name)
        element.text = value.to_s
        element
      end
      
      def self.to_value(xml_val)
        xml_val.text.to_f 
      end
    end
    
    class DateSerializer
      def self.to_node(member_name, value)
        element = Element.new(member_name)
        element.text = value.to_s
        element
      end
      
      def self.to_value(xml_val)
        Date.parse(xml_val.text.to_s) 
      end
    end
    
    class StringSerializer
      def self.to_node(member_name, value)
        element = Element.new(member_name)
        element.text = value.to_s
        element
      end
      
      def self.to_value(xml_val)
        xml_val.text.to_s
      end
    end
    
    class BooleanSerializer
      def self.to_node(member_name, value)
        element = Element.new(member_name)
        element.text = value ? '1' : '0'
        element
      end
      
      def self.to_value(xml_val)
        xml_val.text.to_s == "1" 
      end
    end
    
    class ObjectSerializer
      def self.to_node(member_name, value)
        Document.new(value.to_xml(member_name))
      end
      
      def self.to_value(xml_val)
        FreshBooks::const_get(xml_val.name.camelize)::new_from_xml(xml_val) 
      end
    end
    
    class ArraySerializer
      def self.to_node(member_name, value)
        element = Element.new(member_name)
        value.each { |array_elem|
          element.add_element(Document.new(array_elem.to_xml))
        }
        element
      end
      
      def self.to_value(xml_val)
        xml_val.elements.map { |elem|
          FreshBooks::const_get(elem.name.camelize)::new_from_xml(elem)
        }
      end
    end
    
    class DateTimeSerializer
      def self.to_node(member_name, value)
        element = Element.new(member_name)
        element.text = value.to_s(:db)
        element
      end
      
      def self.to_value(xml_val)
        DateTime.parse(xml_val.text.to_s) 
      end
    end
  end
end
