module FreshBooks
  module Schema
    class Definition
      attr_reader :members
      
      def initialize
        @members = ActiveSupport::OrderedHash.new
      end
      
      def method_missing(method, *attributes)
        options = attributes.extract_options!
        options[:read_only] ||= false
        
        attributes.each do |attribute|
          @members[attribute.to_s] = options.merge({ :type => method.to_sym })
        end
      end
    end
  end
end
