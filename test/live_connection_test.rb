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
    assert FreshBooks::Invoice.list("per_page" => 100).size == 0
    invoice = FreshBooks::Invoice.new
    invoice.client_id = @client.client_id
    assert invoice.create
    assert FreshBooks::Invoice.list("per_page" => 100).size == 1
    notes = invoice.notes
    invoice.notes = "updated notes"
    assert invoice.update
    assert notes != FreshBooks::Invoice.get(invoice.invoice_id).notes
    assert FreshBooks::Invoice.get(invoice.invoice_id).delete
    assert FreshBooks::Invoice.list("per_page" => 100).size == 0
  end
  
  def test_expenses
    assert FreshBooks::Expense.list("per_page" => 100).size == 0
    expense = FreshBooks::Expense.new
    staff = FreshBooks::Staff.list("per_page" => 1).first
    puts staff
    puts staff_id
    expense.staff_id = staff.staff_id
    expense.category_id = @category.category_id
    expense.amount = $100
    assert expense.create
    assert FreshBooks::Expense.list("per_page" => 100).size == 1
    notes = expense.notes
    expense.notes = "updated notes"
    assert expense.update
    assert notes != FreshBooks::Expense.get(expense.expense_id).notes
    assert FreshBooks::Expense.get(expense.expense_id).delete
    assert FreshBooks::Expense.list("per_page" => 100).size == 0
  end
  # def test_invoice
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 0
  #   invoice = FreshBooks::Invoice.new
  #   invoice.client_id = @client.client_id
  #   assert invoice.create
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 1
  #   notes = invoice.notes
  #   invoice.notes = "updated notes"
  #   assert invoice.update
  #   assert notes != FreshBooks::Invoice.get(invoice.invoice_id).notes
  #   assert FreshBooks::Invoice.get(invoice.invoice_id).delete
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 0
  # end
  # def test_invoice
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 0
  #   invoice = FreshBooks::Invoice.new
  #   invoice.client_id = @client.client_id
  #   assert invoice.create
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 1
  #   notes = invoice.notes
  #   invoice.notes = "updated notes"
  #   assert invoice.update
  #   assert notes != FreshBooks::Invoice.get(invoice.invoice_id).notes
  #   assert FreshBooks::Invoice.get(invoice.invoice_id).delete
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 0
  # end
  # def test_invoice
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 0
  #   invoice = FreshBooks::Invoice.new
  #   invoice.client_id = @client.client_id
  #   assert invoice.create
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 1
  #   notes = invoice.notes
  #   invoice.notes = "updated notes"
  #   assert invoice.update
  #   assert notes != FreshBooks::Invoice.get(invoice.invoice_id).notes
  #   assert FreshBooks::Invoice.get(invoice.invoice_id).delete
  #   assert FreshBooks::Invoice.list("per_page" => 100).size == 0
  # end
  
end