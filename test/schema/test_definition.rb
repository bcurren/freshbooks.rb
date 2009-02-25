require File.dirname(__FILE__) + '/../test_helper.rb'

module Schema
  class TestDefinition < Test::Unit::TestCase
    def setup
      @definition = FreshBooks::Schema::Definition.new
    end
    
    def test_method_missing
      # Empty
      assert_equal 0, @definition.members.size
      
      # One type
      @definition.string :name
      assert_equal 1, @definition.members.size
      assert_equal({ :type => :string }, @definition.members["name"])
      
      # Multiple attributes
      @definition.fixnum :version, :po_number
      assert_equal 3, @definition.members.size
      assert_equal({ :type => :fixnum }, @definition.members["version"])
      assert_equal({ :type => :fixnum }, @definition.members["po_number"])
      
      # Multiple times
      @definition.fixnum :lock_number
      assert_equal 4, @definition.members.size
      assert_equal({ :type => :fixnum }, @definition.members["lock_number"])
    end
  end
end