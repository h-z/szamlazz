# frozen_string_literal: true

require "nokogiri"

module Szamlazz
  class InvoiceBuilder
    XMLNS_INVOICE = "http://www.szamlazz.hu/xmlszamla"
    XMLNS_REVERSE = "http://www.szamlazz.hu/xmlszamlast"
    XMLNS_CREDIT = "http://www.szamlazz.hu/xmlszamlakifiz"
    XMLNS_PDF = "http://www.szamlazz.hu/xmlszamlapdf"
    XMLNS_XML = "http://www.szamlazz.hu/xmlszamlaxml"
    XMLNS_REMOVE_PROFORM = "http://www.szamlazz.hu/xmlszamladbkdel"
    XSI = "http://www.w3.org/2001/XMLSchema-instance"
    LOCATION_INVOICE = "http://www.szamlazz.hu/xmlszamla https://www.szamlazz.hu/szamla/docs/xsds/agent/xmlszamla.xsd"
    LOCATION_REVERSE = "http://www.szamlazz.hu/xmlszamlast https://www.szamlazz.hu/szamla/docs/xsds/agentst/xmlszamlast.xsd"
    LOCATION_CREDIT = "http://www.szamlazz.hu/xmlszamlakifiz https://www.szamlazz.hu/szamla/docs/xsds/agentkifiz/xmlszamlakifiz.xsd"
    LOCATION_PDF = "http://www.szamlazz.hu/xmlszamlapdf https://www.szamlazz.hu/szamla/docs/xsds/agentpdf/xmlszamlapdf.xsd"
    LOCATION_XML = "http://www.szamlazz.hu/xmlszamlaxml https://www.szamlazz.hu/szamla/docs/xsds/agentpdf/xmlszamlaxml.xsd"
    LOCATION_REMOVE_PROFORM = "http://www.szamlazz.hu/xmlszamladbkdel https://www.szamlazz.hu/szamla/docs/xsds/agentpdf/xmlszamladbkdel.xsd"

    # @param [Szamlazz::Client] client
    def initialize(client)
      @client = client
    end

    # @param [Szamlazz::Invoice] invoice
    # @return [Nokogiri::XML::Builder]
    def build_invoice(invoice)
      create_builder.tap do |builder|
        builder.xmlszamla(xmlns: XMLNS_INVOICE, "xmlns:xsi": XSI, "xsi:schemaLocation": LOCATION_INVOICE) do |root|
          root.beallitasok do |b|
            b.felhasznalo(client.user) if client.user
            b.jelszo(client.password) if client.password
            b.szamlaagentkulcs(client.token) if client.token
            b.eszamla(client.einvoice || false)
            b.szamlaLetoltes(client.download_invoice || false)
            b.valaszVerzio(2)
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
            h.arfolyam(invoice.exchange_rate || 0)
            h.rendelesSzam(invoice.order_id)
            h.dijbekeroSzamlaszam(invoice.proform_invoice_id)
            h.elolegszamla(invoice.prepayment_invoice || false)
            h.vegszamla(invoice.final_invoice || false)
            h.helyesbitoszamla(invoice.correction_invoice || false)
            h.dijbekero(invoice.proform || false)
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
            b.sendEmail(invoice.buyer.send_email || false)
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
      end
    end

    # @param [string] invoice_id
    def build_reverse_invoice(invoice_id)
      create_builder.tap do |builder|
        builder.xmlszamlast(xmlns: XMLNS_REVERSE, "xmlns:xsi": XSI, "xsi:schemaLocation": LOCATION_REVERSE) do |root|
          root.beallitasok do |b|
            b.felhasznalo(client.user) if client.user
            b.jelszo(client.password) if client.password
            b.szamlaagentkulcs(client.token) if client.token
            b.eszamla(client.einvoice || false)
            b.szamlaLetoltes(client.download_invoice || false)
            b.szamlaLetoltesPld(1)
            b.valaszVerzio(2)
          end
          root.fejlec do |h|
            h.szamlaszam(invoice_id)
            h.keltDatum(Date.today)
          end
        end
      end
    end

    # @param [string] invoice_id
    # @param [Array<Szamlazz::Payment>] payments
    # @param [boolean] additive
    def build_credit_invoice(invoice_id, payments, additive)
      create_builder.tap do |builder|
        builder.xmlszamlakifiz(xmlns: XMLNS_CREDIT, "xmlns:xsi": XSI, "xsi:schemaLocation": LOCATION_CREDIT) do |root|
          root.beallitasok do |b|
            b.felhasznalo(client.user) if client.user
            b.jelszo(client.password) if client.password
            b.szamlaagentkulcs(client.token) if client.token
            b.szamlaszam(invoice_id)
            b.additiv(additive)
            b.valaszVerzio(2)
          end
          payments.each do |payment|
            root.kifizetes do |p|
              p.datum(payment.date)
              p.jogcim(payment.title)
              p.osszeg(payment.amount)
              p.leiras(payment.description)
            end
          end
        end
      end
    end

    # @param [string] invoice_id
    def build_download_invoice_pdf(invoice_id)
      create_builder.tap do |builder|
        builder.xmlszamlapdf(xmlns: XMLNS_PDF, "xmlns:xsi": XSI, "xsi:schemaLocation": LOCATION_PDF) do |root|
          root.felhasznalo(client.user) if client.user
          root.jelszo(client.password) if client.password
          root.szamlaagentkulcs(client.token) if client.token
          root.szamlaszam(invoice_id)
          root.valaszVerzio(2)
        end
      end
    end

    # @param [string] invoice_id
    def build_download_invoice_xml(invoice_id)
      create_builder.tap do |builder|
        builder.xmlszamlaxml(xmlns: XMLNS_XML, "xmlns:xsi": XSI, "xsi:schemaLocation": LOCATION_XML) do |root|
          root.felhasznalo(client.user) if client.user
          root.jelszo(client.password) if client.password
          root.szamlaagentkulcs(client.token) if client.token
          root.szamlaszam(invoice_id)
        end
      end
    end

    # @param [string] invoice_id
    # @param [string] order_id
    def build_remove_proform_invoice_xml(invoice_id = nil, order_id = nil)
      create_builder.tap do |builder|
        builder.xmlszamladbkdel(xmlns: XMLNS_REMOVE_PROFORM, "xmlns:xsi": XSI,
                                "xsi:schemaLocation": LOCATION_REMOVE_PROFORM) do |root|
          root.beallitasok do |b|
            b.felhasznalo(client.user) if client.user
            b.jelszo(client.password) if client.password
            b.szamlaagentkulcs(client.token) if client.token
          end
          root.fejlec do |h|
            h.szamlaszam(invoice_id) if invoice_id
            h.rendelesszam(order_id) if order_id
          end
        end
      end
    end

    private

    def create_builder
      Nokogiri::XML::Builder.new
    end

    attr_reader :invoice, :client
  end
end
