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

require 'net/https'
require 'rexml/document'

include REXML

module FreshBooks
  VERSION = '2.2.1'     # Gem version
  API_VERSION = '2.1' # FreshBooks API version

  SERVICE_URL = "/api/#{API_VERSION}/xml-in"

  class InternalError < Exception; end;
  class AuthenticationError < Exception; end;
  class UnknownSystemError < Exception; end;
  class InvalidParameterError < Exception; end;
  class ApiAccessNotEnabled < Exception; end;
  class InvalidAccountUrl < Exception; end;


  @@account_url, @@auth_token = ''
  @@response = nil
  @@request_headers = nil

  def self.setup(account_url, auth_token, request_headers = {})
    raise InvalidAccountUrl.new unless account_url =~ /^[0-9a-zA-Z\-_]+\.freshbooks\.com$/
    
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

      raise InternalError.new,         error_msg if error_msg =~ /not formatted correctly/
      raise AuthenticationError.new,   error_msg if error_msg =~ /[Aa]uthentication failed/
      raise UnknownSystemError.new,    error_msg if error_msg =~ /does not exist/
      raise InvalidParameterError.new, error_msg if error_msg =~ /Invalid parameter: (.*)/
      raise ApiAccessNotEnabled.new, error_msg if error_msg =~ /API access for this account is not enabled/
      
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

    result.body
  end

  class Response
    attr_accessor :doc
    def initialize(xml_raw)
      @doc = Document.new xml_raw
    end

    def elements
      @doc.root.elements
    end

    def success?
      @doc.root.attributes['status'] == 'ok'
    end

    def fail?
      !success?
    end

    def error_msg
      return @doc.root.elements['error'].text
    end
  end


  #--------------------------------------------------------------------------
  # BaseObject
  #==========================================================================

  class BaseObject < Struct
    attr_accessor :resp

    # Rails-like accessor to member variables
    #def attributes; return members; end;

    # Maps field names ('invoice_id') to Ruby types (Fixnum)
    TYPE_MAPPINGS = {}

    # Maps field names ('url') to mutability (nil for mutable; :read_only for read-only)
    MUTABILITY = {}

    # Anonymous methods for converting an XML element to its
    # corresponding Ruby type
    MAPPING_FNS = {
      Fixnum     => lambda { |xml_val| xml_val.text.to_i },
      Float      => lambda { |xml_val| xml_val.text.to_f },
      BaseObject => lambda { |xml_val| BaseObject.class::new_from_xml },
      Array      => lambda do |xml_val|
        xml_val.elements.map do |elem|
          FreshBooks::const_get(elem.name.capitalize)::new_from_xml(elem)
        end
      end
    }

    # Create a new instance of this class from an XML element
    def self.new_from_xml(xml_root)
      object = self.new

      self.members.each do |field_name|
        node = xml_root.elements[field_name]

        next if node.nil?

        mapping = self::TYPE_MAPPINGS[field_name]
        if mapping
          object[field_name] = self::MAPPING_FNS[mapping].call(node)
        else
          object[field_name] = node.text.to_s
        end
      end
      return object
    end

    # Convert an instance of this class to an XML element
    def to_xml(elem_name = nil)
      # The root element is the class name, downcased
      elem_name ||= self.class.to_s.split('::').last.downcase
      root = Element.new elem_name

      # Add each BaseObject member to the root elem
      self.members.each do |field_name|
        next if self.class::MUTABILITY[field_name.to_sym] == :read_only

        value = self.send(field_name)

        if value.is_a?(Array)
          node = root.add_element(field_name)
          value.each { |array_elem|
            array_elem_name = 'line' if field_name == 'lines'
            node.add_element(array_elem.to_xml(array_elem_name))
          }
        elsif !value.nil?
          root.add_element(field_name).text = value
        end
      end
      root
    end

  end

  #--------------------------------------------------------------------------
  # Clients
  #==========================================================================

  Client = BaseObject.new(:client_id, :first_name, :last_name, :organization,
    :email, :username, :password, :work_phone, :home_phone, :mobile, :fax,
    :notes, :p_street1, :p_street2, :p_city, :p_state, :p_country, :p_code,
    :s_street1, :s_street2, :s_city, :s_state, :s_country, :s_code, :url, :auth_url)

  class Client
    TYPE_MAPPINGS = { 'client_id' => Fixnum }
    def create
      resp = FreshBooks::call_api('client.create', 'client' => self)
      if resp.success?
        self.client_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.client_id : nil
    end

    def update
      resp = FreshBooks::call_api('client.update', 'client' => self)

      resp.success?
    end

    def delete
      Client::delete(self.client_id)
    end

    def self.get(client_id)
      resp = FreshBooks::call_api('client.get', 'client_id' => client_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('client.list', options)
      
      return nil unless resp.success?

      client_elems = resp.elements[1].elements
      client_elems.map { |elem| self.new_from_xml(elem) }
    end

    def self.delete(client_id)
      resp = FreshBooks::call_api('client.delete', 'client_id' => client_id)

      resp.success?
    end

    def invoices(options = {})
      options.merge( 'client_id' => self.client_id )

      Invoice::list(options)
    end
  end

  #--------------------------------------------------------------------------
  # Invoices
  #==========================================================================

  Invoice = BaseObject.new(:invoice_id, :client_id, :number, :date, :po_number,
  :terms, :first_name, :last_name, :organization, :p_street1, :p_street2, :p_city,
  :p_state, :p_country, :p_code, :amount, :lines, :discount, :status, :notes, :url, :auth_url)


  class Invoice
    TYPE_MAPPINGS = { 'client_id' => Fixnum, 'lines' => Array,
    'po_number' => Fixnum, 'discount' => Float, 'amount' => Float }

    MUTABILITY = { 
      :url => :read_only,
      :auth_url => :read_only 
    }

    def initialize
      super
      self.lines ||= []
    end

    def create
      resp = FreshBooks::call_api('invoice.create', 'invoice' => self)
      if resp.success?
        self.invoice_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.invoice_id : nil
    end

    def update
      resp = FreshBooks::call_api('invoice.update', 'invoice' => self)

      resp.success?
    end

    def delete; Invoice::delete(self.invoice_id); end;
    def send_by_email; Invoice::send_by_email(self.invoice_id); end;
    def send_by_snail_mail; Invoice::send_by_snail_mail(self.invoice_id); end;
    
    def self.get(invoice_id)
      resp = FreshBooks::call_api('invoice.get', 'invoice_id' => invoice_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.delete(invoice_id)
      resp = FreshBooks::call_api('invoice.delete', 'invoice_id' => invoice_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('invoice.list', options)
      
      return nil unless resp.success?

      invoice_nodes = resp.elements[1].elements
      invoice_nodes.map { |elem| self.new_from_xml(elem) }
    end

    def self.send_by_email(invoice_id)
      resp = FreshBooks::call_api('invoice.sendByEmail', 'invoice_id' => invoice_id)

      resp.success?
    end

    def self.send_by_snail_mail(invoice_id)
      resp = FreshBooks::call_api('invoice.sendBySnailMail', 'invoice_id' => invoice_id)

      resp.success?
    end

  end

  Line = BaseObject.new(:name, :description, :unit_cost, :quantity, :tax1_name,
    :tax2_name, :tax1_percent, :tax2_percent, :amount)

  class Line
    TYPE_MAPPINGS = { 'unit_cost' => Float, 'quantity' => Fixnum,
      'tax1_percent' => Float, 'tax2_percent' => Float, 'amount' => Float }
  end

  #--------------------------------------------------------------------------
  # Items
  #==========================================================================

  Item = BaseObject.new(:item_id, :name, :description, :unit_cost,
    :quantity, :inventory)
  class Item
    TYPE_MAPPINGS = { 'item_id' => Fixnum, 'unit_cost' => Float,
      'quantity' => Fixnum, 'inventory' => Fixnum }

    def create
      resp = FreshBooks::call_api('item.create', 'item' => self)
      if resp.success?
        self.item_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.item_id : nil
    end

    def update
      resp = FreshBooks::call_api('item.update', 'item' => self)

      resp.success?
    end

    def delete
      Item::delete(self.item_id)
    end
    
    def self.get(item_id)
      resp = FreshBooks::call_api('item.get', 'item_id' => item_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.delete(item_id)
      resp = FreshBooks::call_api('item.delete', 'item_id' => item_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('item.list', options)
      
      return nil unless resp.success?

      item_elems = resp.elements[1].elements
      item_elems.map { |elem| self.new_from_xml(elem) }
    end
  end

  #--------------------------------------------------------------------------
  # Payments
  #==========================================================================

  Payment = BaseObject.new(:payment_id, :client_id, :invoice_id, :date, :amount, :type, :notes)
  class Payment
    TYPE_MAPPINGS = { 'client_id' => Fixnum, 'invoice_id' => Fixnum, 'amount' => Float }

    def create
      resp = FreshBooks::call_api('payment.create', 'payment' => self)
      if resp.success?
        self.payment_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.payment_id : nil
    end

    def update
      resp = FreshBooks::call_api('payment.update', 'payment' => self)

      resp.success?
    end

    def self.get(payment_id)
      resp = FreshBooks::call_api('payment.get', 'payment_id' => payment_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('payment.list', options)

      return nil unless resp.success?

      payment_elems = resp.elements[1].elements
      payment_elems.map { |elem| self.new_from_xml(elem) }
    end
  end

  #--------------------------------------------------------------------------
  # Recurring Profiles
  #==========================================================================

  Recurring = BaseObject.new(:recurring_id, :client_id, :date, :po_number,
  :terms, :first_name, :last_name, :organization, :p_street1, :p_street2, :p_city,
  :p_state, :p_country, :p_code, :amount, :lines, :discount, :status, :notes,
  :occurrences, :frequency, :send_email, :send_snail_mail)


  class Recurring
    TYPE_MAPPINGS = { 'client_id' => Fixnum, 'lines' => Array,
      'po_number' => Fixnum, 'discount' => Float, 'amount' => Float,
      'occurrences' => Fixnum }

    def initialize
      super
      self.lines ||= []
    end

    def create
      resp = FreshBooks::call_api('recurring.create', 'recurring' => self)
      if resp.success?
        self.invoice_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.invoice_id : nil
    end

    def update
      resp = FreshBooks::call_api('recurring.update', 'recurring' => self)

      resp.success?
    end

    def self.get(recurring_id)
      resp = FreshBooks::call_api('recurring.get', 'recurring_id' => recurring_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def delete
      Recurring::delete(self.recurring_id)
    end

    def self.delete(recurring_id)
      resp = FreshBooks::call_api('recurring.delete', 'recurring_id' => recurring_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('recurring.list', options)

      return nil unless resp.success?

      recurring_elems = resp.elements[1].elements

      recurring_elems.map { |elem| self.new_from_xml(elem) }
    end

  end
  
  Project = BaseObject.new(:project_id, :client_id, :name, :bill_method, :rate,
  :description, :tasks)
  
  class Project
    TYPE_MAPPINGS = { 'project_id' => Fixnum, 'client_id' => Fixnum,
      'rate' => Float, 'tasks' => Array
    }
    
    def initialize
      super
      self.tasks ||= []
    end

    def create
      resp = FreshBooks::call_api('project.create', 'project' => self)
      if resp.success?
        self.project_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.project_id : nil
    end

    def update
      resp = FreshBooks::call_api('project.update', 'project' => self)

      resp.success?
    end

    def self.get(project_id)
      resp = FreshBooks::call_api('project.get', 'project_id' => project_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def delete
      Project::delete(self.project_id)
    end

    def self.delete(project_id)
      resp = FreshBooks::call_api('project.delete', 'project_id' => project_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('project.list', options)

      return nil unless resp.success?

      project_elems = resp.elements[1].elements

      project_elems.map { |elem| self.new_from_xml(elem) }
    end
  end
  
  Task = BaseObject.new(:task_id, :name, :billable, :rate, :description)
  
  class Task
    TYPE_MAPPINGS = { 'task_id' => Fixnum, 'rate' => Float }
    
    def create
      resp = FreshBooks::call_api('task.create', 'task' => self)
      if resp.success?
        self.task_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.task_id : nil
    end

    def update
      resp = FreshBooks::call_api('task.update', 'task' => self)

      resp.success?
    end

    def self.get(task_id)
      resp = FreshBooks::call_api('task.get', 'task_id' => task_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def delete
      Task::delete(self.task_id)
    end

    def self.delete(task_id)
      resp = FreshBooks::call_api('task.delete', 'task_id' => task_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('task.list', options)

      return nil unless resp.success?

      task_elems = resp.elements[1].elements

      task_elems.map { |elem| self.new_from_xml(elem) }
    end
  end
  
  TimeEntry = BaseObject.new(:time_entry_id, :project_id, :task_id, :hours,
  :notes, :date)
  
  class TimeEntry
    TYPE_MAPPINGS = { 'time_entry_id' => Fixnum, 'project_id' => Fixnum,
      'task_id' => Fixnum, 'hours' => Float }
    
    def create
      resp = FreshBooks::call_api('time_entry.create', 'time_entry' => self)
      if resp.success?
        self.time_entry_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.time_entry_id : nil
    end

    def update
      resp = FreshBooks::call_api('time_entry.update', 'time_entry' => self)

      resp.success?
    end

    def self.get(time_entry_id)
      resp = FreshBooks::call_api('time_entry.get', 'time_entry_id' => time_entry_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def delete
      TimeEntry::delete(self.time_entry_id)
    end

    def self.delete(time_entry_id)
      resp = FreshBooks::call_api('time_entry.delete', 'time_entry_id' => time_entry_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('time_entry.list', options)

      return nil unless resp.success?

      time_entry_elems = resp.elements[1].elements

      time_entry_elems.map { |elem| self.new_from_xml(elem) }
    end
  end
  
  #--------------------------------------------------------------------------
  # Estimates
  #==========================================================================

  Estimate = BaseObject.new(:estimate_id, :client_id, :status, :date, :po_number, :discount, :notes,
    :terms, :first_name, :last_name, :organization, :p_street1, :p_street2, :p_city, :p_state, :p_country,
    :p_code, :lines)


  class Estimate
    TYPE_MAPPINGS = { 'client_id' => Fixnum, 'lines' => Array, 
    'po_number' => Fixnum, 'discount' => Float, 'amount' => Float }

    def initialize
      super
      self.lines ||= []
    end

    def create
      resp = FreshBooks::call_api('estimate.create', 'invoice' => self)
      if resp.success?
        self.invoice_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.invoice_id : nil
    end

    def update
      resp = FreshBooks::call_api('invoice.update', 'estimate' => self)

      resp.success?
    end

    def delete; Estimate::delete(self.estimate_id); end;
    def send_by_email; Estimate::send_by_email(self.estimate_id); end;
    
    def self.get(estimate_id)
      resp = FreshBooks::call_api('estimate.get', 'estimate_id' => estimate_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.delete(estimate_id)
      resp = FreshBooks::call_api('estimate.delete', 'estimate_id' => estimate_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('estimate.list', options)
      return nil unless resp.success?

      estimate_nodes = resp.elements[1].elements
      estimate_nodes.map { |elem| self.new_from_xml(elem) }
    end

    def self.send_by_email(estimate_id)
      resp = FreshBooks::call_api('estimate.sendByEmail', 'estimate_id' => estimate_id)

      resp.success?
    end
  end    

end

