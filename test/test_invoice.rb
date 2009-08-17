require File.dirname(__FILE__) + '/test_helper.rb'

class TestInvoice < Test::Unit::TestCase
  def test_list
    mock_call_api("invoice.list", { "page" => 1 }, "invoice_list_response")
    
    invoices = FreshBooks::Invoice.list
    assert_equal 3, invoices.size
    assert_invoice invoices[0], 0
    assert_invoice invoices[1], 1
  end
  
  def test_get
    invoice_id = 2
    mock_call_api("invoice.get", { "invoice_id" => invoice_id }, "invoice_get_response")
    
    invoice = FreshBooks::Invoice.get(invoice_id)
    assert_invoice invoice, 0, true
  end
  
  def test_create
    invoice = FreshBooks::Invoice.new
    assert_nil invoice.invoice_id
    
    mock_call_api("invoice.create", { "invoice" => invoice }, "invoice_create_response")
    assert invoice.create
    assert_equal 1, invoice.invoice_id
  end
  
  def test_update
    invoice = FreshBooks::Invoice.new
    invoice.invoice_id = 1
    
    mock_call_api("invoice.update", { "invoice" => invoice }, "success_response")
    assert invoice.update
  end
  
  def test_delete
    invoice = FreshBooks::Invoice.new
    invoice.invoice_id = 2
    mock_call_api("invoice.delete", { "invoice_id" => invoice.invoice_id }, "success_response")
    
    assert invoice.delete
  end
  
  def test_send_by_email
    invoice = FreshBooks::Invoice.new
    invoice.invoice_id = 2
    mock_call_api("invoice.sendByEmail", { "invoice_id" => invoice.invoice_id }, "success_response")
    
    assert invoice.send_by_email
  end
  
  def test_send_by_snail_mail
    invoice = FreshBooks::Invoice.new
    invoice.invoice_id = 2
    mock_call_api("invoice.sendBySnailMail", { "invoice_id" => invoice.invoice_id }, "success_response")
    
    assert invoice.send_by_snail_mail
  end
  
private
  
  def mock_call_api(method, options, response_fixture)
    FreshBooks::Base.connection.
      expects(:call_api).
      with(method, options).
      returns(FreshBooks::Response.new(fixture_xml_content(response_fixture)))
  end
  
  def assert_invoice(invoice, number, expanded_form = false)
    number = number + 1
    
    assert_equal number, invoice.invoice_id
    assert_equal "number#{number}", invoice.number
    assert_equal number, invoice.client_id
    assert_equal number, invoice.recurring_id
    assert_equal "draft", invoice.status
    assert_equal (number * 100), invoice.amount
    assert_equal (number * 100) / 2, invoice.amount_outstanding
    assert_equal Date.parse("2009-02-0#{number}"), invoice.date
    
    assert_equal number, invoice.po_number
    assert_equal number.to_f, invoice.discount
    assert_equal "notes#{number}", invoice.notes
    assert_equal "terms#{number}", invoice.terms
    assert_equal "first_name#{number}", invoice.first_name
    assert_equal "last_name#{number}", invoice.last_name
    assert_equal "p_street1#{number}", invoice.p_street1
    assert_equal "p_street2#{number}", invoice.p_street2
    assert_equal "p_city#{number}", invoice.p_city
    assert_equal "p_state#{number}", invoice.p_state
    assert_equal "p_country#{number}", invoice.p_country
    assert_equal "p_code#{number}", invoice.p_code
    
    assert_equal "return_uri#{number}", invoice.return_uri
    assert_equal DateTime.parse("2009-08-#{number} 0#{number}:00:00 -04:00"), invoice.updated
    
    
    
    assert_equal "client_view#{number}", invoice.links.client_view
    assert_equal "view#{number}", invoice.links.view
    assert_equal "edit#{number}", invoice.links.edit
    
    lines = invoice.lines
    assert_equal 1, lines.size
    lines.each_with_index do |line, index|
      assert_line(line, index)
    end
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
