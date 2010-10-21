$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  require 'active_support'
rescue LoadError
  require 'rubygems'
  gem 'activesupport'
  require 'active_support'
end
require 'active_support/all'

require 'freshbooks/base'
require 'freshbooks/category'
require 'freshbooks/client'
require 'freshbooks/connection'
require 'freshbooks/estimate'
require 'freshbooks/expense'
require 'freshbooks/invoice'
require 'freshbooks/item'
require 'freshbooks/line'
require 'freshbooks/links'
require 'freshbooks/list_proxy'
require 'freshbooks/payment'
require 'freshbooks/project'
require 'freshbooks/recurring'
require 'freshbooks/response'
require 'freshbooks/staff'
require 'freshbooks/task'
require 'freshbooks/time_entry'

require 'net/https'
require 'rexml/document'
require 'logger'

#------------------------------------------------------------------------------
# FreshBooks.rb - Ruby interface to the FreshBooks API
#
# Copyright (c) 2007-2008 Ben Vinegar (http://www.benlog.org)
#
# This work is distributed under an MIT License:
# http://www.opensource.org/licenses/mit-license.php
#
#------------------------------------------------------------------------------
# Usage:
#
# FreshBooks.setup('sample.freshbooks.com', 'mytoken')
#
# clients = FreshBooks::Client.list
# client = clients[0]
# client.first_name = 'Suzy'
# client.update
#
# invoice = FreshBooks::Invoice.get(4)
# invoice.lines[0].quantity += 1
# invoice.update
#
# item = FreshBooks::Item.new
# item.name = 'A sample item'
# item.create
#
#==============================================================================
module FreshBooks
  VERSION = '3.0.24'     # Gem version
  API_VERSION = '2.1' # FreshBooks API version
  SERVICE_URL = "/api/#{API_VERSION}/xml-in"

  class Error < StandardError; end;
  class InternalError < Error; end;
  class AuthenticationError < Error; end;
  class UnknownSystemError < Error; end;
  class InvalidParameterError < Error; end;
  class ApiAccessNotEnabledError < Error; end;
  class InvalidAccountUrlError < Error; end;
  class AccountDeactivatedError < Error; end;
  
  class ParseError < StandardError
    attr_accessor :original_error, :xml

    def initialize(original_error, xml, msg = nil)
      @original_error = original_error
      @xml = xml
      super(msg)
    end

    def to_s
      message = super

      "Original Error: #{original_error.to_s}\n" +
      "XML: #{xml.to_s}\n" +
      "Message: #{message}\n"
    end
  end
end

