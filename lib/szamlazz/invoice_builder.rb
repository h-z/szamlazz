# frozen_string_literal: true

require "nokogiri"

module Szamlazz
  class InvoiceBuilder
    # @param [Szamlazz::Client] client
    def initialize(client)
      @client = client
    end

    # @param [Szamlazz::Invoice] invoice
    def build_invoice(invoice)
      @invoice = invoice

      xmlns = "http://www.szamlazz.hu/xmlszamla"
      xsi = "http://www.w3.org/2001/XMLSchema-instance"
      location = "http://www.szamlazz.hu/xmlszamla https://www.szamlazz.hu/szamla/docs/xsds/agent/xmlszamla.xsd"

      builder.xmlszamla(xmlns:, "xmlns:xsi": xsi, "xsi:schemaLocation": location) do |root|
        root.beallitasok do |b|
          b.felhasznalo(client.user) if client.user
          b.jelszo(client.password) if client.password
          b.szamlaagentkulcs(client.token) if client.token
          b.eszamla(!client.einvoice.nil?)
          b.szamlaLetoltes(client.download_invoice)
          b.valaszVerzio(client.response_version)
          b.aggregator(nil)
          b.szamlaKulsoAzon(invoice.external_key)
        end
        root.fejlec do |h|
          h.keltDatum(invoice.issue_date)
          h.teljesitesDatum(invoice.fulfillment_date)
          h.fizetesiHataridoDatum(invoice.due_date)
          h.fizmod(invoice.payment_method)
          h.penznem(invoice.currency)
          h.szamlaNyelve(invoice.language)
          h.megjegyzes(invoice.comment)
          h.arfolyamBank(invoice.exchange_bank)
          h.arfolyam(invoice.exchange_rate)
          h.rendelesSzam(invoice.order_id)
          h.dijbekeroSzamlaszam(invoice.proform_invoice_id)
          h.elolegszamla(invoice.prepayment_invoice)
          h.vegszamla(invoice.final_invoice)
          h.helyesbitoszamla(invoice.correction_invoice)
          h.dijbekero(invoice.proform)
          h.szamlaszamElotag(invoice.prefix)
        end
        root.elado do |s|
          s.bank(invoice.seller.bank_name)
          s.bankszamlaszam(invoice.seller.bank_account)
          s.emailReplyto(invoice.seller.email_address)
          s.emailTargy(invoice.seller.email_subject)
          s.emailSzoveg(invoice.seller.email_message)
        end
        root.vevo do |b|
          b.nev(invoice.buyer.name)
          b.irsz(invoice.buyer.address.zip)
          b.telepules(invoice.buyer.address.city)
          b.cim(invoice.buyer.address.address)
          b.email(invoice.buyer.email)
          b.sendEmail(invoice.buyer.send_email)
          b.adoszam(invoice.buyer.tax_number)
          b.postazasiNev(invoice.buyer.post_address.name)
          b.postazasiIrsz(invoice.buyer.post_address.zip)
          b.postazasiTelepules(invoice.buyer.post_address.city)
          b.postazasiCim(invoice.buyer.post_address.address)
          b.azonosito(invoice.buyer.identifier)
          b.telefonszam(invoice.buyer.phone)
          b.megjegyzes(invoice.buyer.comment)
        end
        root.tetelek do |i|
          invoice.items.each do |item|
            i.tetel do |ii|
              ii.megnevezes(item.label)
              ii.mennyiseg(item.quantity)
              ii.mennyisegiEgyseg(item.unit)
              ii.nettoEgysegar(item.net_unit_price)
              ii.afakulcs(item.vat)
              ii.nettoErtek(item.net_value)
              ii.afaErtek(item.vat_value)
              ii.bruttoErtek(item.gross_value)
              ii.megjegyzes(item.comment)
            end
          end
        end
      end

      builder
    end

    private

    def builder
      @builder ||= Nokogiri::XML::Builder.new
    end

    attr_reader :invoice, :client
  end
end
