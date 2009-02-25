require 'net/https'
require 'rexml/document'
require 'logger'

module FreshBooks
  class Connection
    attr_reader :account_url, :auth_token, :request_headers
    
    @@logger = Logger.new(STDOUT)
    def logger
      @@logger
    end

    def self.log_level=(level)
      @@logger.level = level
    end
    self.log_level = Logger::WARN
    
    def initialize(account_url, auth_token, request_headers = {})
      raise InvalidAccountUrlError.new unless account_url =~ /^[0-9a-zA-Z\-_]+\.freshbooks\.com$/
      
      @account_url = account_url
      @auth_token = auth_token
      @request_headers = request_headers
    end
    
    def call_api(method, elements = [])
      request = create_request(method, elements)
      result = post(request)
      Response.new(result)
    end
    
  protected
    
    def create_request(method, elements = [])
      doc = Document.new '<?xml version="1.0" encoding="UTF-8"?>'
      request = doc.add_element('request')
      request.attributes['method'] = method
      
      elements.each do |element|
        if element.kind_of?(Hash)
          element = element.to_a
        end
        key = element.first
        value = element.last
        
        if value.is_a?(BaseObject) || value.is_a?(Base)
          request.add_element(value.to_xml)
        else
          request.add_element(Element.new(key.to_s)).text = value.to_s
        end
      end
      
      doc.to_s
    end
    
    def post(request_body)
      connection = Net::HTTP.new(@account_url, 443)
      connection.use_ssl = true
      connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request = Net::HTTP::Post.new(FreshBooks::SERVICE_URL)
      request.basic_auth @auth_token, 'X'
      request.body = request_body
      request.content_type = 'application/xml'
      @request_headers.each_pair do |name, value|
        request[name.to_s] = value
      end
      
      result = connection.start  { |http| http.request(request) }
      
      if logger.debug?
        logger.debug "Request:"
        logger.debug request_body
        logger.debug "Response:"
        logger.debug result.body
      end
      
      check_for_api_error(result)
    end
    
    def check_for_api_error(result)
      return result.body if result.class == Net::HTTPSuccess
      
      case result
      when Net::HTTPRedirection
        if result["location"] =~ /loginSearch/
          raise UnknownSystemError.new("Account does not exist")
        elsif result["location"] =~ /deactivated/
          raise AccountDeactivatedError.new("Account is deactivated")
        end
      when Net::HTTPUnauthorized
        raise AuthenticationError.new("Invalid API key.")
      when Net::HTTPBadRequest
        raise ApiAccessNotEnabledError.new("API not enabled.")
      end
      
      raise InternalError.new("Invalid HTTP code: #{result.class}")
    end
  end
end
