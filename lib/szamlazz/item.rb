# frozen_string_literal: true

module Szamlazz
  class Item < Base
    ZERO_VAT = %w[TAM AAM EU EUK MAA ÁKK TEHK HO KBAET].freeze

    attr_accessor :label, :quantity, :unit, :vat, :net_unit_price, :gross_unit_price, :comment, :vat_value, :net_value,
                  :gross_value

    def initialize(params)
      super

      raise ArgumentError, "missing VAT" if @vat.nil?

      raise ArgumentError, "missing quantity" if @quantity.nil?

      calculate_values
    end

    private

    def vat_percentage
      @vat_percentage ||= (ZERO_VAT.include?(vat) ? 0 : vat)
    end

    def calculate_values
      if !net_unit_price.nil?
        @net_value = (net_unit_price * quantity).round(2)
        @vat_value = (net_value * vat_percentage / 100.0).round(2)
        @gross_value = net_value + vat_value
      elsif !gross_unit_price.nil?
        @gross_value = (gross_unit_price * quantity).round(2)
        @vat_value = (gross_value / (vat_percentage + 100.0) * vat_percentage).round(2)
        @net_value = gross_value - vat_value
        @net_unit_price = (net_value / quantity).round(2)
      else
        raise ArgumentError, "missing unit price"
      end
    end
  end
end
