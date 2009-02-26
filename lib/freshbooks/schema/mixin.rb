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
          schema_definition.members.each do |member|
            process_schema_member(member)
          end
        end
        
        def process_schema_member(member)
          member_name = member.first
          member_options = member.last
          
          # Create accessor
          attr_accessor member_name
          
          # Protect write if read only
          if member_options[:read_only]
            protected "#{member_name}="
          end
        end
      end
    end
  end
end
