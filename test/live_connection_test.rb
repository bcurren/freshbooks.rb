require File.dirname(__FILE__) + '/test_helper.rb'

# this tests a live conection
class LiveConnectionTest < Test::Unit::TestCase
  fixtures :freshbooks_credentials
  
  def setup
    fb_account_info = freshbooks_credentials(:fresh_books_test_account)
    FreshBooks::Base.establish_connection(fb_account_info['account_url'], fb_account_info['api_key'])
  end

  # just go out there and get a live connection and see if it returns anything
  def test_live_connection        
    FreshBooks::Base.connection.start_session do
      clients = FreshBooks::Client.list("per_page" => 1)
      FreshBooks::Invoice.list("per_page" => 100).collect do |invoice|
        assert FreshBooks::Invoice.get(invoice.invoice_id)
      end 
    end
  end

end