require 'net/https'
require 'rexml/document'
require 'logger'

module FreshBooks
  class Connection
    attr_reader :account_url, :auth_token, :utc_offset, :request_headers
    
    @@logger = Logger.new(STDOUT)
    def logger
      @@logger
    end

    def logger=(value)
      @@logger = value
    end

    def self.log_level=(level)
      @@logger.level = level
    end
    self.log_level = Logger::WARN
    
    def initialize(account_url, auth_token, request_headers = {}, options = {})
      raise InvalidAccountUrlError.new unless account_url =~ /^[0-9a-zA-Z\-_]+\.freshbooks\.com$/
      
      @account_url = account_url
      @auth_token = auth_token
      @request_headers = request_headers
      @utc_offset = options[:utc_offset] || -4
      @start_session_count = 0
    end
    
    def call_api(method, elements = [])
      request = create_request(method, elements)
      result = post(request)
      Response.new(result)
    end
    
    def direct_post(xml)
      result = post(xml)
      Response.new(result)
    end
    
    def start_session(&block)
      @connection = obtain_connection if @start_session_count == 0
      @start_session_count = @start_session_count + 1
      
      begin
        block.call(@connection)
      ensure
        @start_session_count = @start_session_count - 1
        close if @start_session_count == 0
      end
    end
    
  protected
    
    def create_request(method, elements = [])
      doc = REXML::Document.new '<?xml version="1.0" encoding="UTF-8"?>'
      request = doc.add_element('request')
      request.attributes['method'] = method
      
      elements.each do |element|
        if element.kind_of?(Hash)
          element = element.to_a
        end
        key = element.first
        value = element.last
        
        if value.kind_of?(Base)
          request.add_element(REXML::Document.new(value.to_xml))
        else
          request.add_element(REXML::Element.new(key.to_s)).text = value.to_s
        end
      end
      
      doc.to_s
    end
    
    def obtain_connection(force = false)
      return @connection if @connection && !force
      
      @connection = Net::HTTP.new(@account_url, 443)
      @connection.use_ssl = true
      @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @connection.start
    end
    
    def reconnect
      close
      obtain_connection(true)
    end
    
    def close
      begin
        @connection.finish if @connection
      rescue => e
        logger.error("Error closing connection: " + e.message)
      end
      @connection = nil
    end
    
    def post(request_body)
      result = nil
      request = Net::HTTP::Post.new(FreshBooks::SERVICE_URL)
      request.basic_auth @auth_token, 'X'
      request.body = request_body
      request.content_type = 'application/xml'
      @request_headers.each_pair do |name, value|
        request[name.to_s] = value
      end
      
      result = post_request(request)
      
      if logger.debug?
        logger.debug "Request:"
        logger.debug request_body
        logger.debug "Response:"
        logger.debug result.body
      end
      
      check_for_api_error(result)
    end
    
    # For connections that take a long time, we catch EOFError's and reconnect seamlessly
    def post_request(request)
      response = nil
      has_reconnected = false
      start_session do |connection|
        begin
          response = connection.request(request)
        rescue EOFError => e
          raise e if has_reconnected
          
          has_reconnected = true
          connection = reconnect
          retry
        end
      end
      response
    end
    
    def check_for_api_error(result)
      return result.body if result.kind_of?(Net::HTTPSuccess)
      
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
