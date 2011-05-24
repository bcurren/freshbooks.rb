require File.dirname(__FILE__) + '/../lib/freshbooks'

require 'stringio'
require 'test/unit'
require File.dirname(__FILE__) + '/mock_connection'
require 'active_support/all'

begin
  require 'mocha'
rescue LoadError
  require 'rubygems'
  gem 'mocha'
  require 'mocha'
end

class Test::Unit::TestCase

  @@fixtures = {}
  def self.fixtures list
    [list].flatten.each do |fixture|
      self.class_eval do
        # add a method name for this fixture type
        define_method(fixture) do |item|
          # load and cache the YAML
          @@fixtures[fixture] ||= YAML::load_file(self.fixture_dir + "/#{fixture.to_s}.yml")
          @@fixtures[fixture][item.to_s]
        end
      end
    end
  end


  def mock_connection(file_name)
    mock_connection = MockConnection.new(fixture_xml_content(file_name))
    FreshBooks::Base.stubs(:connection).with().returns(mock_connection)
    mock_connection
  end

  def fixture_xml_content(file_name)
    # Quick way to remove white space and newlines from xml. Makes it easier to compare in tests
    open(File.join(fixture_dir, "#{file_name}.xml"), "r").readlines.inject("") do |contents, line|
      contents + line.strip
    end
  end

  def fixture_dir
    File.join(File.dirname(__FILE__), "fixtures")
  end

  def assert_line(line, number)
    number = number + 1

    assert_equal number.to_f, line.amount
    assert_equal "name#{number}", line.name
    assert_equal "description#{number}", line.description
    assert_equal number.to_f, line.unit_cost
    assert_equal number, line.quantity
    assert_equal "tax1_name#{number}", line.tax1_name
    assert_equal "tax2_name#{number}", line.tax2_name
    assert_equal number.to_f, line.tax1_percent
    assert_equal number.to_f, line.tax2_percent
  end
end
