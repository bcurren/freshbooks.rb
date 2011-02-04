module FreshBooks
  class Page < Array
    attr_reader :page, :per_page, :total

    def initialize(page, per_page, total, array)
      super(array)
      @page = page.to_i
      @per_page = per_page.to_i
      @total = total.to_i
    end
  
    # Get the page number that this element is on given the number of elements per page
    def page_number(position)
      (position / per_page) + 1
    end
  
    # Get the position number of this element based relative to the current page
    def position_number(position)
      position - ((page - 1) * per_page)
    end
  
    def pages
      return 0 if per_page == 0
    
      pages = total / per_page
    
      if (total % per_page) != 0
        pages += 1
      end
      pages
    end
  
    def next_page?
      page < pages
    end
  end
end
