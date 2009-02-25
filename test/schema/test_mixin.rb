require File.dirname(__FILE__) + '/../test_helper.rb'

module Schema
  class TestMixin < Test::Unit::TestCase
    def test_define_schema__unique_definition_per_class
      assert MyItem.schema_definition.members.include?("name")
      assert !MyItem.schema_definition.members.include?("name2")
    
      assert MyItem2.schema_definition.members.include?("name2")
      assert !MyItem2.schema_definition.members.include?("name")
    end
    
    def test_define_schema__creates_attr_accessors
      assert MyItem.public_method_defined?("name")
      assert MyItem.public_method_defined?("name=")
      
      assert MyItem2.public_method_defined?("name2")
      assert MyItem2.public_method_defined?("name2=")
    end
    
    def test_define_schema__creates_read_only_attr_accessors
      assert MyItem.public_method_defined?("read_only_name")
      assert MyItem.protected_method_defined?("read_only_name=")
    end
  end

  class MyItem < FreshBooks::Base
    define_schema do |s|
      s.string :name
      s.string :read_only_name, :read_only => true
    end
  end

  class MyItem2 < FreshBooks::Base
    define_schema do |s|
      s.string :name2
    end
  end
end