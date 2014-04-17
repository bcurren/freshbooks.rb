module FreshBooks
  class Invoice < FreshBooks::Base
    require "#{Dir.pwd}/app/models/txns/invoice.rb"

    define_schema do |s|
      s.fixnum :invoice_id, :client_id, :po_number, :staff_id
      s.fixnum :recurring_id, :read_only => true
      s.float :amount, :discount
      s.float :amount_outstanding, :paid, :read_only => true
      s.date :date
      s.date_time :updated, :read_only => true
      s.array :lines
      s.object :links, :read_only => true
      s.string :number, :organization, :status, :notes, :terms, :first_name, :last_name, :currency_code, :language
      s.string :p_street1, :p_street2, :p_city, :p_state, :p_country, :p_code
      s.string :return_uri
    end
    
    actions :list, :get, :create, :update, :delete, :send_by_email, :send_by_snail_mail

    # Custom FreshBooks -> QuickBooks stuff
    KEY_CONVERSION = HashWithIndifferentAccess.new({ invoice_id: 'id', client_id: 'customer_id', staff_id: 'edited_by', notes: 'memo', number: 'ref_number',
                       amount_outstanding: 'balance_remaining', date: 'ship_date', updated: 'updated_at' })

    # Make a hash with keys whose values are the name of the function to call in order to convert freshbooks data to quickbooks data.
    # EX: first_name: :convert_name. convert_name would assign first_name + last_name to customer_full_name in QB doc


    def convert_to_active_record
      if invoice = ::Invoice.where(:freshbooks_id => self.invoice_id).first # TODO - still need verification that documents are the same
        return invoice
      end

      invoice = ::Invoice.new

      self.schema_definition.members.each do |key, key_info|
        # begin
          if key_info[:type] != :array
            new_key, new_value = convert_key(key)
            next if new_key == '[NEXT]'
            invoice.send(new_key + '=', new_value)
          else
            # Item lines
            self.send(key).each do |line|
              next if quantity == 0.0 # Freshbooks sends blank lines too
              new_line = invoice.invoice_lines.new

              # If line.type == 'Item', find or create company item by name (verify by unit_cost)
              # new_line.item_id = found_item.id
              # new_line.quantity = line.quantity

              # line.schema_definition.members.each do |line_key, line_key_info|
              #   new_line_key, new_line_value = convert_line_key(line, line_key)
              #   next if new_key == '[NEXT]'
              #   invoice.send(new_line_key + '=', new_line_value)
              # end
            end
          end
        # rescue => e
        #   puts e.inspect
        # end
      end

      # TODO - verify totals
      return invoice
    end

    def convert_key(old_key)
      if KEY_CONVERSION.include?(old_key)
        return KEY_CONVERSION[old_key], self.send(old_key)
      end

      # TODO - temp. Keys I haven't matched yet or that don't need to be brought over.
      ignored_keys = %w(recurring_id amount paid links language p_street1 p_street2 p_city p_state p_country p_code return_uri)
      if ignored_keys.include?(old_key)
        return '[NEXT]'
      end

      case old_key.to_sym
      when :first_name
        return 'customer_full_name', self.send(old_key) + ' ' + self.send(:last_name)
      when :last_name
        return '[NEXT]'
      when :organization
        # TODO - Should first and last name or organization take preference?
        return 'customer_full_name', self.send(old_key)
      when :terms
        # TODO - Find or create company terms by terms_full_name
        return '[NEXT]'
      when :currency_code
        # TODO - Find currency by abbreviation. Ex: CAD = Canadian Dollar
        return '[NEXT]'
      when :discount
        # TODO - Find or create a discount item and use in item line
        return '[NEXT]'
      else
        return old_key.to_s, self.send(old_key)
      end
    end

    def convert_line_key(line, old_line_key)
      case old_line_key.to_sym
      when :name
        # TODO - find item by name and verify by price
      else
        return old_line_key.to_s, line.send(old_line_key)
      end
    end

    def amount_without_tax

    end
  end
end
