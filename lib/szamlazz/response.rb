# frozen_string_literal: true

require "nokogiri"

module Szamlazz
  class Response
    def initialize(body)
      @body = Nokogiri::XML(body)
      @body.remove_namespaces!

      check_response
    end

    def success?
      success == "true"
    end

    {
      "szamlaszam" => :invoice_number,
      "szamlanetto" => :net_total,
      "szamlabrutto" => :gross_total,
      "vevoifiokurl" => :buyer_account_url,
      "kintlevoseg" => :account_receivable,
      "hibakod" => :error_code,
      "hibauzenet" => :error_message,
      "sikeres" => :success,
      "pdf" => :pdf_file
    }.each { |key, value| define_method(value) { body.xpath("//#{key}").text } }

    def pdf
      Base64.decode64(pdf_file)
    end

    private

    attr_reader :body

    def check_response
      return if success?

      raise Szamlazz::Error, "#{error_code}: #{error_message}"
    end
  end
end
