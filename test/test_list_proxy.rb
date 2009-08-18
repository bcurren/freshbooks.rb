require File.dirname(__FILE__) + '/test_helper.rb'

class TestListProxy < Test::Unit::TestCase
  def test_size__should_be_total_size_of_results
    list_proxy = FreshBooks::ListProxy.new(create_proc(1, 2, 3))
    assert_equal 3, list_proxy.size
  end
  
  def test_reference_element
    list_proxy = FreshBooks::ListProxy.new(create_proc(1, 2, 3))
    assert_equal 0, list_proxy[0]
    assert_equal 1, list_proxy[1]
    assert_equal 2, list_proxy[2]
  end
  
  def test_each
    list_proxy = FreshBooks::ListProxy.new(create_proc(1, 2, 3))
    count = 0
    list_proxy.each_with_index do |item, i|
      assert_equal i, item, "Incorrect item on iteration #{i}"
      count += 1
    end
    assert_equal count, list_proxy.size
  end
  
  def test_each__no_pages_and_items
    list_proxy = FreshBooks::ListProxy.new(create_proc(0, 0, 0))
    count = 0
    list_proxy.each_with_index do |item, i|
      count += 1
    end
    assert_equal 0, list_proxy.size
    assert_equal 0, count
  end
  
  def test_each__response_doesnt_have_pagination_but_returns_items
    list_proxy = FreshBooks::ListProxy.new(create_proc(0, 0, 0, 3))
    count = 0
    list_proxy.each_with_index do |item, i|
      count += 1
    end
    assert_equal 3, list_proxy.size
    assert_equal 3, count
  end
  
private 
  
  def create_proc(page, per_page, total, total_in_array = total)
    get_page_proc = proc do |page|
      start_num = (page - 1) * per_page
      end_num = start_num + per_page
      if end_num >= total_in_array || end_num == 0
        end_num = total_in_array
      end
      
      array = Range.new(start_num, end_num, true).to_a
      [array, FreshBooks::Page.new(page, per_page, total, total_in_array)]
    end
  end
end
