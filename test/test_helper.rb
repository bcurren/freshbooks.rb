require 'rubygems'
require 'test/unit'

begin
  require 'mocha'
  require 'active_support'
rescue LoadError
  require 'rubygems'
  gem 'mocha'
  require 'mocha'
  gem 'activesupport'
  require 'active_support'
end

require 'stringio'
require 'fakeweb'
require File.dirname(__FILE__) + '/../lib/freshbooks'

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
  
  def mock_api_response(response_fixture)
    FakeWeb.allow_net_connect = false
    FreshBooks::Base.establish_connection('company.freshbooks.com', 'auth_token')
    FakeWeb.register_uri(:any, "https://auth_token:X@company.freshbooks.com/api/2.1/xml-in", :body => File.read(File.dirname(__FILE__) + "/fixtures/#{response_fixture}.xml"))
  end
      
  def fixture_dir
    File.join(File.dirname(__FILE__), "fixtures")
  end
end
