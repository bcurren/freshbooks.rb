module FreshBooks
  class ListProxy
    include Enumerable
    
    def initialize(call_api_proc, klass, options = {})
      @call_api_proc = call_api_proc
      @klass = klass
      @options = options
      move_to_page(@options["page"] ? @options["page"].to_i : 1)
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
      
      @options["page"] = page
      response = @call_api_proc.call(@options)
      raise FreshBooks::InternalError.new("Response was not successful. This should never happen.") unless response.success?
      parse_response(response)
    end
    
    def parse_response(response)
      root = response.elements[1]
      @array = root.elements.map { |item| @klass.new_from_xml(item) }
      @current_page = Page.new(root.attributes['page'], root.attributes['per_page'], root.attributes['total'])
      true
    end
  end
  
  class Page
    attr_reader :page, :per_page, :total
    
    def initialize(page, per_page, total)
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
