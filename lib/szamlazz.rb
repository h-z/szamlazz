# frozen_string_literal: true

require_relative "szamlazz/version"

module Szamlazz
  class Error < StandardError; end

  class Base
    def initialize(params)
      @params = params
      params.each { |key, value| __send__("#{key}=", value) }
    end
  end

  class Address < Base
    attr_accessor :name, :country, :zip, :city, :address
  end

  class Seller < Base
    attr_accessor :bank_name, :bank_account, :email_address, :email_subject, :email_message
  end

  class Buyer < Base
    attr_accessor :address, :post_address, :tax_number, :issuer_name, :identifier, :phone, :comment, :send_email,
                  :name, :email
  end

  class Invoice < Base
    attr_accessor :payment_method, :currency, :language, :seller, :buyer, :items, :prepayment_invoice, :external_key,
                  :issue_date, :fulfillment_date, :due_date, :exchange_bank, :exchange_rate, :order_id, :comment,
                  :proform_invoice_id, :final_invoice, :correction_invoice, :proform, :prefix
  end
end

require_relative "szamlazz/client"
require_relative "szamlazz/item"
require_relative "szamlazz/invoice_builder"
