require File.dirname(__FILE__) + '/test_helper.rb'

class TestExpense < Test::Unit::TestCase
  def test_list
    mock_api_response("expense_list_response")
    
    expenses = FreshBooks::Expense.list
    assert_equal 47, expenses.size
    assert_expense expenses[0], 0
    assert_expense expenses[1], 1
  end
  
  def test_get
    expense_id = 2
    mock_api_response("expense_get_response")
    
    expense = FreshBooks::Expense.get(expense_id)
    assert_expense expense, 0, true
  end
  
  def test_create
    expense = FreshBooks::Expense.new
    assert_nil expense.expense_id
    
    mock_api_response("expense_create_response")
    assert expense.create
    assert_equal 433, expense.expense_id
  end
  
  def test_update
    expense = FreshBooks::Expense.new
    expense.expense_id = 1
    
    mock_api_response("success_response")
    assert expense.update
  end
  
  def test_delete
    expense = FreshBooks::Expense.new
    expense.expense_id = 2
    mock_api_response("success_response")
    
    assert expense.delete
  end
    
private


  def assert_expense(expense, number, expanded_form = false)
    number = number + 1
    
    assert_equal number, expense.expense_id
    assert_equal number, expense.staff_id
    assert_equal number, expense.category_id
    assert_equal number, expense.project_id
    assert_equal number, expense.client_id
    assert_equal (number * 100), expense.amount
    assert_equal Date.parse("2011-01-0#{number}"), expense.date
    assert_equal "notes#{number}", expense.notes
    assert_equal "folder#{number}", expense.folder
    assert_equal "vendor#{number}", expense.vendor
    assert_equal "status#{number}", expense.status
  end
end
