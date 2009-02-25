require File.dirname(__FILE__) + '/test_helper.rb'

class TestBase < Test::Unit::TestCase
  def test_establish_connection
    assert_nil FreshBooks::Base.connection
    
    FreshBooks::Base.establish_connection("company.freshbooks.com", "auth_token")
    connection = FreshBooks::Base.connection
    assert_not_nil connection
    assert_equal "company.freshbooks.com", connection.account_url
    assert_equal "auth_token", connection.auth_token
    
    FreshBooks::Base.establish_connection("company2.freshbooks.com", "auth_token2")
    connection = FreshBooks::Base.connection
    assert_not_nil connection
    assert_equal "company2.freshbooks.com", connection.account_url
    assert_equal "auth_token2", connection.auth_token
  end
  
  def test_new_from_xml_to_xml__round_trip
    xml = <<-EOS
      <my_item>
        <name>name1</name>
        <amount>4.5</amount>
        <number>5</number>
        <date>2008-02-01</date>
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
    doc = Document.new(xml)
    
    item = FreshBooks::MyItem.new_from_xml(doc.root)
    assert_equal "name1", item.name
    assert_equal 5, item.number
    assert_equal 4.5, item.amount
    assert_equal Date.new(2008, 2, 1), item.date
    assert_equal "street1", item.my_address.street1
    assert_equal 1, item.my_lines.size
    assert_equal "description", item.my_lines.first.description
    
    # If someone knows a good way to compare xml docs where ordering doesn't matter
    # let me know. This can be refactored and improved greatly.
    xml_out = item.to_xml.to_s.strip
    assert_equal "<my_item>", xml_out.first(9)
    assert xml_out.include?("<name>name1</name>")
    assert xml_out.include?("<amount>4.5</amount>")
    assert xml_out.include?("<number>5</number>")
    assert xml_out.include?("<date>2008-02-01</date>")
    assert xml_out.include?("<my_address><street1>street1</street1></my_address>")
    assert xml_out.include?("<my_lines><my_line><description>description</description></my_line></my_lines>")
  end
  
end

module FreshBooks
  class MyItem < FreshBooks::Base
    define_schema do |s|
      s.string :name
      s.fixnum :number
      s.float :amount
      s.date :date
      s.object :my_address
      s.array :my_lines
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
