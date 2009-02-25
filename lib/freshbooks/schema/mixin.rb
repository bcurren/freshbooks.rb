require File.dirname(__FILE__) + '/definition'

module FreshBooks
  module Schema
    module Mixin
      def self.included(base)
        base.extend ClassMethods
      end
    
      module ClassMethods
        def define_schema
          # Create the class method accessor for the schema definition
          cattr_accessor :schema_definition
          self.schema_definition ||= FreshBooks::Schema::Definition.new
        
          # Yield to the block for the user to define the schema
          yield self.schema_definition
        
          # Process the schema additions
          schema_definition.members.each do |member_name, member_properties|
            attr_accessor member_name
          end
        end
      end
    end
  end
end
