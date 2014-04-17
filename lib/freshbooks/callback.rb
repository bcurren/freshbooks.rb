module FreshBooks
  class Callback < FreshBooks::Base
    define_schema do |s|
      s.fixnum :callback_id
      s.string :verifier, :event, :uri
      s.boolean :verified
    end

    actions :create, :verify, :resendToken, :list, :delete
  end
end