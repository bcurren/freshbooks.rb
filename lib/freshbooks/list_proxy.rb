module FreshBooks
  class ListProxy
    attr_reader :page, :per_page, :pages, :total
    def initialize(array, page, per_page, pages, total)
      @array = array
      @page = page.to_i
      @per_page = per_page.to_i
      @pages = pages.to_i
      @total = total.to_i
    end
    
    def method_missing(method, *args, &block)
      @array.send(method, *args, &block)
    end
  end
end
