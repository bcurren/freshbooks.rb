require File.dirname(__FILE__) + '/../test_helper.rb'

module Schema
  class TestMixin < Test::Unit::TestCase
    def test_define_schema__unique_definition_per_class
      assert MyItem.schema_definition.members.include?("name")
      assert !MyItem.schema_definition.members.include?("name2")
    
      assert MyItem2.schema_definition.members.include?("name2")
      assert !MyItem2.schema_definition.members.include?("name")
    end
    
    def test_define_schema__creates_accessors
      item = MyItem.new
      item.name = "MyName"
      assert_equal "MyName", item.name
      
      item2 = MyItem2.new
      item2.name2 = "MyName2"
      assert_equal "MyName2", item2.name2
    end
  end

  class MyItem < FreshBooks::Base
    define_schema do |s|
      s.string :name
      s.fixnum :version, :po_number
    end
  end

  class MyItem2 < FreshBooks::Base
    define_schema do |s|
      s.string :name2
    end
  end
end