require File.dirname(__FILE__) + '/xml_serializer/serializers'

module FreshBooks
  module XmlSerializer
    def self.to_value(node, type)
      create_serializer(type).to_value(node)
    end
    
    def self.to_node(member_name, value, type)
      create_serializer(type).to_node(member_name, value)
    end
    
    def self.create_serializer(type)
      "FreshBooks::XmlSerializer::#{type.to_s.classify}Serializer".constantize
    end
  end
end
