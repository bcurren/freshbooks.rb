module FreshBooks
  class BaseObject < Struct
    attr_accessor :resp

    # Rails-like accessor to member variables
    #def attributes; return members; end;

    # Maps field names ('invoice_id') to Ruby types (Fixnum)
    TYPE_MAPPINGS = {}

    # Maps field names ('url') to mutability (nil for mutable; :read_only for read-only)
    MUTABILITY = {}

    # Anonymous methods for converting an XML element to its
    # corresponding Ruby type
    MAPPING_FNS = {
      Fixnum     => lambda { |xml_val| xml_val.text.to_i },
      Float      => lambda { |xml_val| xml_val.text.to_f },
      BaseObject => lambda { |xml_val| 
        FreshBooks::const_get(xml_val.name.capitalize)::new_from_xml(xml_val) 
      },
      Date       => lambda { |xml_val| Date.parse(xml_val.text.to_s) },
      Array      => lambda do |xml_val|
        xml_val.elements.map do |elem|
          FreshBooks::const_get(elem.name.capitalize)::new_from_xml(elem)
        end
      end
    }

    # Create a new instance of this class from an XML element
    def self.new_from_xml(xml_root)
      object = self.new

      self.members.each do |field_name|
        node = xml_root.elements[field_name]

        next if node.nil?

        mapping = self::TYPE_MAPPINGS[field_name]
        if mapping
          object[field_name] = self::MAPPING_FNS[mapping].call(node)
        else
          object[field_name] = node.text.to_s
        end
      end
      return object
    end

    # Convert an instance of this class to an XML element
    def to_xml(elem_name = nil)
      # The root element is the class name, downcased
      elem_name ||= self.class.to_s.split('::').last.downcase
      root = Element.new elem_name

      # Add each BaseObject member to the root elem
      self.members.each do |field_name|
        next if self.class::MUTABILITY[field_name.to_sym] == :read_only

        value = self.send(field_name)

        if value.is_a?(Array)
          node = root.add_element(field_name)
          value.each { |array_elem|
            array_elem_name = 'line' if field_name == 'lines'
            node.add_element(array_elem.to_xml(array_elem_name))
          }
        elsif !value.nil?
          root.add_element(field_name).text = value
        end
      end
      root
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