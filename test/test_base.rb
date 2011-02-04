require File.dirname(__FILE__) + '/test_helper.rb'
require 'base64'

class TestBase < Test::Unit::TestCase
  def test_establish_connection
    assert_nil FreshBooks::Base.connection
    
    FreshBooks::Base.establish_connection("company.freshbooks.com", "auth_token")
    connection = FreshBooks::Base.connection
    assert_not_nil connection
    assert_equal "company.freshbooks.com", connection.account_url
    assert_equal "Basic YXV0aF90b2tlbjpY", connection.auth_token
    assert_equal FreshBooks::BasicAuth, connection.auth.class
    
    FreshBooks::Base.establish_connection("company2.freshbooks.com", "auth_token2")
    connection = FreshBooks::Base.connection
    assert_not_nil connection
    assert_equal "company2.freshbooks.com", connection.account_url
    assert_equal "Basic YXV0aF90b2tlbjI6WA==", connection.auth_token
    assert_equal FreshBooks::BasicAuth, connection.auth.class
    
    FreshBooks::OAuth.any_instance.stubs(:nonce).returns("nonce")
    FreshBooks::OAuth.any_instance.stubs(:timestamp).returns("timestamp")
    FreshBooks::Base.establish_connection("company.freshbooks.com", {"consumer_key"=>"consumer_key", "consumer_secret"=>"consumer_secret", "token"=>"token", "token_secret"=>"token_secret"})
    connection = FreshBooks::Base.connection
    assert_not_nil connection
    assert_equal "company.freshbooks.com", connection.account_url
    assert_equal 'OAuth realm="",oauth_signature_method="PLAINTEXT",oauth_version="1.0",oauth_signature="consumer_secret%26token_secret",oauth_consumer_key="consumer_key",oauth_token="token",oauth_timestamp="timestamp",oauth_nonce="nonce"', connection.auth_token
    assert_equal FreshBooks::OAuth, connection.auth.class
    
    FreshBooks::Base.establish_connection("company2.freshbooks.com", {"consumer_key"=>"consumer_key2", "consumer_secret"=>"consumer_secret2", "token"=>"token2", "token_secret"=>"token_secret2"})
    connection = FreshBooks::Base.connection
    assert_not_nil connection
    assert_equal "company2.freshbooks.com", connection.account_url
    assert_equal 'OAuth realm="",oauth_signature_method="PLAINTEXT",oauth_version="1.0",oauth_signature="consumer_secret2%26token_secret2",oauth_consumer_key="consumer_key2",oauth_token="token2",oauth_timestamp="timestamp",oauth_nonce="nonce"', connection.auth_token
    assert_equal FreshBooks::OAuth, connection.auth.class
    
  end
  
  def test_new_from_xml_to_xml__round_trip
    xml = <<-EOS
      <my_item>
        <name>name1</name>
        <amount>4.5</amount>
        <read_only_number>5</read_only_number>
        <number>6</number>
        <visible>1</visible>
        <date>2008-02-01</date>
        <created_at>2008-10-22 13:57:00</created_at>
        <my_address>
          <street1>street1</street1>
        </my_address>
        <my_lines>
          <my_line>
            <description>description</description>
          </my_line>
        </my_lines>
      </my_item>
    EOS
    doc = REXML::Document.new(xml)
    
    item = FreshBooks::MyItem.new_from_xml(doc.root)
    assert_equal "name1", item.name
    assert_equal 5, item.read_only_number
    assert_equal 6, item.number
    assert_equal 4.5, item.amount
    assert_equal true, item.visible
    assert_equal Date.new(2008, 2, 1), item.date
    assert_equal DateTime.parse("2008-10-22 13:57:00 -04:00"), item.created_at
    assert_equal "street1", item.my_address.street1
    assert_equal 1, item.my_lines.size
    assert_equal "description", item.my_lines.first.description
    
    # If someone knows a good way to compare xml docs where ordering doesn't matter
    # let me know. This can be refactored and improved greatly.
    xml_out = item.to_xml.to_s.strip
    assert_equal "<my_item>", xml_out.first(9)
    assert xml_out.include?("<name>name1</name>")
    assert xml_out.include?("<amount>4.5</amount>")
    assert xml_out.include?("<visible>1</visible>")
    assert !xml_out.include?("<read_only_number>5</read_only_number>") # this is read only
    assert xml_out.include?("<number>6</number>")
    assert xml_out.include?("<date>2008-02-01</date>")
    assert xml_out.include?("<created_at>2008-10-22 13:57:00</created_at>")
    assert xml_out.include?("<my_address><street1>street1</street1></my_address>")
    assert xml_out.include?("<my_lines><my_line><description>description</description></my_line></my_lines>")
  end
  
  def test_will_parse_xml_with_all_zero_datetime
    xml = <<-EOS
      <payment>
        <payment_id>3507</payment_id>
        <invoice_id>00000006457</invoice_id>
        <date>2009-07-18 00:00:00</date>
        <type>VISA</type>
        <notes/>
        <client_id>3313</client_id>
        <amount>300</amount>
        <updated>0000-00-00 00:00:00</updated>
      </payment>
    EOS
  
    doc = REXML::Document.new(xml)
  
    assert_nothing_raised do 
      item = FreshBooks::PaymentItem.new_from_xml(doc.root)
    end
  end
end

module FreshBooks
  class MyItem < FreshBooks::Base
    define_schema do |s|
      s.string :name
      s.fixnum :read_only_number, :read_only => true
      s.fixnum :number
      s.float :amount
      s.boolean :visible
      s.date :date
      s.date_time :created_at
      s.object :my_address
      s.array :my_lines
    end
  end

  class PaymentItem < FreshBooks::Base
    define_schema do |s|
      s.fixnum :payment_id
      s.fixnum :client_id
      s.string :invoice_id
      s.string :notes
      s.float :amount
      s.date_time :updated
      s.date_time :date
      s.string :type
    end
  end

  class MyAddress < FreshBooks::Base
    define_schema do |s|
      s.string :street1
    end
  end
  
  class MyLine < FreshBooks::Base
    define_schema do |s|
      s.string :description
    end
  end
end
