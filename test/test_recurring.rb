require File.dirname(__FILE__) + '/test_helper.rb'

class TestRecurring < Test::Unit::TestCase
  def test_list
    mock_call_api("recurring.list", { "page" => 1 }, "recurring_list_response")

    recurrings = FreshBooks::Recurring.list
    assert_equal 1, recurrings.size
    assert_recurring recurrings[0], 0
  end

  def test_get
    recurring_id = 2
    mock_call_api("recurring.get", { "recurring_id" => recurring_id }, "recurring_get_response")

    recurring = FreshBooks::Recurring.get(recurring_id)
    assert_recurring recurring, 0, true
  end

  def test_create
    recurring = FreshBooks::Recurring.new
    assert_nil recurring.recurring_id

    mock_call_api("recurring.create", { "recurring" => recurring }, "recurring_create_response")
    assert recurring.create
    assert_equal 1, recurring.recurring_id
  end

  def test_update
    recurring = FreshBooks::Recurring.new
    recurring.recurring_id = 1

    mock_call_api("recurring.update", { "recurring" => recurring }, "success_response")
    assert recurring.update
  end

  def test_delete
    recurring = FreshBooks::Recurring.new
    recurring.recurring_id = 2
    mock_call_api("recurring.delete", { "recurring_id" => recurring.recurring_id }, "success_response")

    assert recurring.delete
  end

private

  def mock_call_api(method, options, response_fixture)
    FreshBooks::Base.connection.
      expects(:call_api).
      with(method, options).
      returns(FreshBooks::Response.new(fixture_xml_content(response_fixture)))
  end

  def assert_recurring(recurring, number, expanded_form = false)
    number = number + 1

    assert_equal number, recurring.recurring_id

    assert_equal 'm', recurring.frequency
    assert_equal number, recurring.occurrences
    assert_equal false, recurring.stopped

    assert_equal number, recurring.client_id
    assert_equal (number * 100), recurring.amount
    assert_equal Date.parse("2011-04-0#{number}"), recurring.date

    assert_equal number, recurring.po_number
    assert_equal number.to_f, recurring.discount
    assert_equal "notes#{number}", recurring.notes
    assert_equal "terms#{number}", recurring.terms

    assert_equal "first_name#{number}", recurring.first_name
    assert_equal "last_name#{number}", recurring.last_name
    assert_equal "organization#{number}", recurring.organization
    assert_equal "p_street1#{number}", recurring.p_street1
    assert_equal "p_street2#{number}", recurring.p_street2
    assert_equal "p_city#{number}", recurring.p_city
    assert_equal "p_state#{number}", recurring.p_state
    assert_equal "p_country#{number}", recurring.p_country
    assert_equal "p_code#{number}", recurring.p_code

    assert_equal "return_uri#{number}", recurring.return_uri
    assert_equal true, recurring.send_email
    assert_equal false, recurring.send_snail_mail

    lines = recurring.lines
    assert_equal 1, lines.size
    lines.each_with_index do |line, index|
      assert_line(line, index)
    end
  end
end
