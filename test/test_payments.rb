require File.dirname(__FILE__) + '/test_helper.rb'

class TestPayments < Test::Unit::TestCase
  def test_list
    mock_api_response("payment_list_response")
    
    payments = FreshBooks::Payment.list
    assert_equal 1, payments.size
    assert_payment payments[0], 0
  end
  
  def test_get
    payment_id = 2
    mock_api_response("payment_get_response")
    
    payment = FreshBooks::Payment.get(payment_id)
    assert_payment payment, 0, true
  end
  
  def test_create
    payment = FreshBooks::Payment.new
    assert_nil payment.payment_id
    
    mock_api_response("payment_create_response")
    assert payment.create
    assert_equal 103, payment.payment_id
  end
  
  def test_update
    payment = FreshBooks::Payment.new
    payment.payment_id = 1
    
    mock_api_response("success_response")
    assert payment.update
  end
  
  def test_delete
    payment = FreshBooks::Payment.new
    payment.payment_id = 2
    mock_api_response("success_response")
    
    assert payment.delete
  end
    
private

  def assert_payment(payment, number, expanded_form = false)
    number = number + 1
    
    assert_equal number, payment.payment_id
    assert_equal number, payment.client_id
    assert_equal number, payment.invoice_id
    assert_equal Date.parse("2011-01-0#{number}"), payment.date
    assert_equal (number * 100), payment.amount
    assert_equal "currency_code#{number}", payment.currency_code
    assert_equal "type#{number}", payment.type
    assert_equal "notes#{number}", payment.notes
    assert_equal DateTime.parse("2011-01-0#{number} 00:00:00 -04:00"), payment.updated
  end
end
