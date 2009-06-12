require File.dirname(__FILE__) + '/../lib/freshbooks'

require 'stringio'
require 'test/unit'
require File.dirname(__FILE__) + '/mock_connection'

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
end
