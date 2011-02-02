require File.dirname(__FILE__) + '/test_helper.rb'

# this tests a live conection
class LiveConnectionTest < Test::Unit::TestCase
  fixtures :freshbooks_credentials
  
  def setup
    fb_account_info = freshbooks_credentials(:fresh_books_test_account)
    FreshBooks::Base.establish_connection(fb_account_info['account_url'], fb_account_info['api_key'])
    FreshBooks::Invoice.list("per_page" => 100).each { |invoice| invoice.delete }
    FreshBooks::Expense.list("per_page" => 100).each { |expense| expense.delete }
    FreshBooks::Payment.list("per_page" => 100).each { |payment| payment.delete }
    FreshBooks::Client.list("per_page" => 100).each { |client| client.delete }
    FreshBooks::Category.list("per_page" => 100).each { |category| category.delete }
    @client = FreshBooks::Client.new
    @client.first_name = 'Jane'
    @client.last_name = 'Doe'
    @client.organization = 'ABC Corp'
    @client.email = 'janedoe@freshbooks.com'
    @client.create
    @category = FreshBooks::Category.new
    @category.name = 'Test Category'
    @category.create
  end

  # just go out there and get a live connection and see if it returns anything
  def test_live_connection_with_start_session
    FreshBooks::Base.connection.start_session do
      clients = FreshBooks::Client.list("per_page" => 1)
      FreshBooks::Invoice.list("per_page" => 100).collect do |invoice|
        assert FreshBooks::Invoice.get(invoice.invoice_id)
      end 
    end
  end
  
  def test_live_connection_without_start_session
    clients = FreshBooks::Client.list("per_page" => 1)
    FreshBooks::Invoice.list("per_page" => 100).collect do |invoice|
      assert FreshBooks::Invoice.get(invoice.invoice_id)
    end 
  end
  
  def test_invoice
    size_of_invoice_list = FreshBooks::Invoice.list("per_page" => 100).size
    invoice = FreshBooks::Invoice.new
    invoice.client_id = @client.client_id
    assert invoice.create
    assert FreshBooks::Invoice.list("per_page" => 100).size == size_of_invoice_list + 1
    notes = invoice.notes
    invoice.notes = "updated notes"
    assert invoice.update
    assert notes != FreshBooks::Invoice.get(invoice.invoice_id).notes
    assert FreshBooks::Invoice.get(invoice.invoice_id).delete
    assert FreshBooks::Invoice.list("per_page" => 100).size == size_of_invoice_list
  end
  
  def test_expense
    size_of_expense_list = FreshBooks::Expense.list("per_page" => 100).size
    expense = FreshBooks::Expense.new
    staff = FreshBooks::Staff.list("per_page" => 1).first
    expense.staff_id = staff.staff_id
    expense.category_id = @category.category_id
    expense.amount = 100
    assert expense.create
    assert FreshBooks::Expense.list("per_page" => 100).size == size_of_expense_list + 1
    notes = expense.notes
    expense.notes = "updated notes"
    assert expense.update
    assert notes != FreshBooks::Expense.get(expense.expense_id).notes
    assert FreshBooks::Expense.get(expense.expense_id).delete
    assert FreshBooks::Expense.list("per_page" => 100).size == size_of_expense_list
  end
  
  def test_payment
    size_of_payment_list = FreshBooks::Payment.list("per_page" => 100).size
    payment = FreshBooks::Payment.new
    payment.client_id = @client.client_id
    
    invoice = FreshBooks::Invoice.new
    invoice.client_id = @client.client_id
    invoice.create
    payment.invoice_id = invoice.invoice_id
    
    assert payment.create
    assert FreshBooks::Payment.list("per_page" => 100).size == size_of_payment_list + 1
    notes = payment.notes
    payment.notes = "updated notes"
    assert payment.update
    assert notes != FreshBooks::Payment.get(payment.payment_id).notes
    assert FreshBooks::Payment.get(payment.payment_id).delete
    assert FreshBooks::Payment.list("per_page" => 100).size == size_of_payment_list
  end
  
  def test_client
    size_of_client_list = FreshBooks::Client.list("per_page" => 100).size
    notes = @client.notes
    @client.notes = "updated notes"
    assert @client.update
    assert notes != FreshBooks::Client.get(@client.client_id).notes
    assert FreshBooks::Client.get(@client.client_id).delete
    assert FreshBooks::Client.list("per_page" => 100).size == size_of_client_list - 1
  end
  
  def test_category
    size_of_category_list = FreshBooks::Category.list("per_page" => 100).size
    name = @category.name
    @category.name = "updated name"
    assert @category.update
    assert name != FreshBooks::Category.get(@category.category_id).name
    assert FreshBooks::Category.get(@category.category_id).delete
    assert FreshBooks::Category.list("per_page" => 100).size == size_of_category_list - 1
  end
end