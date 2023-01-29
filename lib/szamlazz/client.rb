# frozen_string_literal: true

module Szamlazz
  class Client < Base
    def initialize(params)
      super

      check_credentials
    end

    attr_accessor :user, :einvoice, :password, :token, :response_version, :invoice_count, :download_invoice

    private

    def check_credentials
      return if (!user.nil? && !password.nil?) || !token.nil?

      raise ArgumentError
    end
  end
end
