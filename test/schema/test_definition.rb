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
      assert_equal({ :type => :string, :read_only => false }, @definition.members["name"])
      
      # Multiple attributes
      @definition.fixnum :version, :po_number
      assert_equal 3, @definition.members.size
      assert_equal({ :type => :fixnum, :read_only => false }, @definition.members["version"])
      assert_equal({ :type => :fixnum, :read_only => false }, @definition.members["po_number"])
      
      # Multiple times
      @definition.fixnum :lock_number
      assert_equal 4, @definition.members.size
      assert_equal({ :type => :fixnum, :read_only => false }, @definition.members["lock_number"])
    end
    
    def test_method_missing_extra_options
      @definition.fixnum :version, :po_number, :read_only => true
      assert_equal({ :type => :fixnum, :read_only => true }, @definition.members["version"])
      assert_equal({ :type => :fixnum, :read_only => true }, @definition.members["po_number"])
    end
  end
end