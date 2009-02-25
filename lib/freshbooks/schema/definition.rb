module FreshBooks
  module Schema
    class Definition
      attr_reader :members
      
      def initialize
        @members = {}
      end
      
      def method_missing(method, *attributes)
        attributes.each do |attribute|
          @members[attribute.to_s] = { :type => method.to_sym }
        end
      end
    end
  end
end