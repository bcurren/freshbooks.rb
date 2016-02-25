module FreshBooks
  class Task < FreshBooks::Base
    define_schema do |s|
      s.string :name, :email, :facebook_id, :twitter_id, :subject, :type, :description, :description_html
      s.fixnum :requester_id, :phone, :status, :priority, :responder_id
    end

    actions :list, :get, :create, :update, :delete
  end
end
