# frozen_string_literal: true

require "http"
require "pry-byebug"

module Szamlazz
  class Client < Base
    URL = "https://www.szamlazz.hu/szamla/"

    def initialize(params)
      super

      check_credentials
    end

    attr_accessor :user, :einvoice, :password, :token, :invoice_count, :download_invoice

    # @param [Szamlazz::Invoice] invoice
    # @return [Szamlazz::Response]
    def issue_invoice(invoice)
      xml = builder.build_invoice(invoice)
      response = HTTP.post(URL, form: { "action-xmlagentxmlfile": xml.to_xml })
      Response.new(response.body)
    end

    # @param [string] invoice_id
    # @return [Szamlazz::Response]
    def reverse_invoice(invoice_id)
      self.password = "123456"
      xml = builder.build_reverse_invoice(invoice_id)
      response = HTTP.post(URL, form: { "action-szamla_agent_st": xml.to_xml })
      Response.new(response.body)
    end

    # @param [string] invoice_id
    # @param [Array<Szamlazz::Payment>] payments
    # @param [boolean] additive
    # @return [Szamlazz::Response]
    def credit_invoice(invoice_id, payments, additive)
      xml = builder.build_credit_invoice(invoice_id, payments, additive)
      response = HTTP.post(URL, form: { "action-szamla_agent_kifiz": xml.to_xml })
      Response.new(response.body)
    end

    # @param [string] invoice_id
    # @return [Szamlazz::Response]
    def download_invoice_pdf(invoice_id)
      xml = builder.build_download_invoice_pdf(invoice_id)
      response = HTTP.post(URL, form: { "action-szamla_agent_pdf": xml.to_xml })
      Response.new(response.body)
    end

    # @param [string] invoice_id
    # @return [Nokogiri::XML::Document]
    def download_invoice_xml(invoice_id)
      xml = builder.build_download_invoice_xml(invoice_id)
      response = HTTP.post(URL, form: { "action-szamla_agent_xml": xml.to_xml })
      Nokogiri::XML(response.body)
    end

    # @param [string] invoice_id
    # @return [Szamlazz::Response]
    def remove_proform_invoice(invoice_id)
      xml = builder.build_remove_proform_invoice_xml(invoice_id)
      response = HTTP.post(URL, form: { "action-szamla_agent_dijbekero_torlese": xml.to_xml })
      Response.new(response.body)
    end

    private

    def builder
      @builder ||= InvoiceBuilder.new(self)
    end

    def check_credentials
      return if (!user.nil? && !password.nil?) || !token.nil?

      raise ArgumentError, "Either user and password or token must be provided"
    end
  end
end
