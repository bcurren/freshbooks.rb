module FreshBooks
  class Links < FreshBooks::Base
    define_schema do |s|
      s.string :client_view, :view, :edit, :statement, :read_only => true
    end
  end
end
