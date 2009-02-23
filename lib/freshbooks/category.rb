module FreshBooks
  Category = BaseObject.new(:category_id, :name, :tax1, :tax2)
  
  class Category
    TYPE_MAPPINGS = { 'category_id' => Fixnum, 'tax1' => Float,
      'tax2' => Float }

    def create
      resp = FreshBooks::call_api('category.create', 'category' => self)
      if resp.success?
        self.category_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.category_id : nil
    end

    def update
      resp = FreshBooks::call_api('category.update', 'category' => self)

      resp.success?
    end

    def delete
      Category::delete(self.category_id)
    end
    
    def self.get(category_id)
      resp = FreshBooks::call_api('category.get', 'category_id' => category_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def self.delete(category_id)
      resp = FreshBooks::call_api('category.delete', 'category_id' => category_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('category.list', options)
      
      return nil unless resp.success?

      category_elems = resp.elements[1].elements
      category_elems.map { |elem| self.new_from_xml(elem) }
    end
  end
end