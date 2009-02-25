$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  require 'active_support'
rescue LoadError
  require 'rubygems'
  gem 'activesupport'
  require 'active_support'
end

require 'freshbooks/connection'
require 'freshbooks/base'
require 'freshbooks/invoice'

require 'net/https'
require 'rexml/document'
require 'logger'

include REXML

require 'freshbooks/response'
require 'freshbooks/base_object'
require 'freshbooks/client'
require 'freshbooks/payment'
require 'freshbooks/recurring'
require 'freshbooks/project'
require 'freshbooks/task'
require 'freshbooks/time_entry'
require 'freshbooks/estimate'
require 'freshbooks/expense'
require 'freshbooks/category'
require 'freshbooks/staff'
require 'freshbooks/list_proxy'

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
  VERSION = '3.0.0'     # Gem version
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

  @@logger = Logger.new(STDOUT)
  def self.logger
    @@logger
  end
  
  def self.log_level=(level)
    @@logger.level = level
  end
  self.log_level = Logger::WARN
  
  @@account_url, @@auth_token = ''
  @@response = nil
  @@request_headers = nil

  def self.setup(account_url, auth_token, request_headers = {})
    raise InvalidAccountUrlError.new unless account_url =~ /^[0-9a-zA-Z\-_]+\.freshbooks\.com$/
    
    @@account_url = account_url
    @@auth_token = auth_token
    @@request_headers = request_headers

    true
  end

  def self.last_response
    @@response
  end

  def self.call_api(method, elems = [])
    doc = Document.new '<?xml version="1.0" encoding="UTF-8"?>'
    request = doc.add_element 'request'
    request.attributes['method'] = method

    elems.each do |key, value|
      if value.is_a?(BaseObject)
        elem = value.to_xml
        request.add_element elem
      else
        request.add_element(Element.new(key)).text = value.to_s
      end
    end

    result = self.post(request.to_s)

    @@response = Response.new(result)

    #
    # Failure
    #
    if @@response.fail?
      error_msg = @@response.error_msg

      raise InternalError.new(error_msg) if error_msg =~ /not formatted correctly/
      raise AuthenticationError.new(error_msg) if error_msg =~ /[Aa]uthentication failed/
      raise UnknownSystemError.new(error_msg) if error_msg =~ /does not exist/
      raise InvalidParameterError.new(error_msg) if error_msg =~ /Invalid parameter: (.*)/
      raise ApiAccessNotEnabledError.new(error_msg) if error_msg =~ /API access for this account is not enabled/
      
      # Raise an exception for unexpected errors
      raise error_msg
    end

    @@response
  end

  def self.post(body)
    connection = Net::HTTP.new(@@account_url, 443)
    connection.use_ssl = true
    connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(FreshBooks::SERVICE_URL)
    request.basic_auth @@auth_token, 'X'
    request.body = body
    request.content_type = 'application/xml'
    @@request_headers.each_pair do |name, value|
      request[name.to_s] = value
    end
    
    result = connection.start  { |http| http.request(request) }
    case result
      when Net::HTTPSuccess
        # Good, just continue
      when Net::HTTPRedirection
        # FreshBooks is returning 302 when account_url is valid but an account with the given 
        # name doesn't exist. Translate to an unknown system error. Open question on forums
        # to figure out why this is happening. http://forum.freshbooks.com/viewtopic.php?pid=14170#p14170
        if result["location"] =~ /loginSearch/
          raise UnknownSystemError.new("Account does not exist")
        elsif result["location"] =~ /deactivated/
          raise AccountDeactivatedError.new("Account is deactived")
        else
          raise InternalError.new("Invalid http code: #{result.class}")
        end
      when Net::HTTPUnauthorized
        raise AuthenticationError.new("Invalid API key.")
      when Net::HTTPBadRequest
        raise ApiAccessNotEnabledError.new("API not enabled.")
      else
        raise InternalError.new("Invalid http code: #{result.class}")
    end
    
    if logger.debug?
      logger.debug "Request:"
      logger.debug body
      logger.debug "Response:"
      logger.debug result.body
    end
    
    result.body
  end
end

