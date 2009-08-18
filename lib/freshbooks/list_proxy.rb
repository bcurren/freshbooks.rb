module FreshBooks
  class ListProxy
    include Enumerable
    
    def initialize(list_page_proc)
      @list_page_proc = list_page_proc
      move_to_page(1)
    end
    
    def each(&block)
      move_to_page(1)
      
      begin
        @array.each(&block)
      end while @current_page.next_page? && next_page
    end
    
    def [](position)
      move_to_page(@current_page.page_number(position))
      @array[@current_page.position_number(position)]
    end
    
    def size
      @current_page.total
    end
    
  private
    
    def next_page
      move_to_page(@current_page.page + 1)
    end
    
    def move_to_page(page)
      return true if @current_page && @current_page.page == page
      @array, @current_page = @list_page_proc.call(page)
    end
  end
  
  class Page
    attr_reader :page, :per_page, :total
    
    def initialize(page, per_page, total, total_in_array = total)
      @page = page.to_i
      @per_page = per_page.to_i
      @total = total.to_i
      
      # Detect if response has pagination
      if @per_page == 0 && @total == 0 && total_in_array != 0
        # No pagination so fake it
        @page = 1
        @per_page = @total = total_in_array
      end
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
