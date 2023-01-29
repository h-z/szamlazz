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
    attr_accessor :address, :post_address, :tax_number, :issuer_name, :identifier, :phone, :comment
  end

  class Item < Base
    attr_accessor :label, :quantity, :unit, :vat, :net_unit_price, :gross_unit_price, :comment
  end
end
