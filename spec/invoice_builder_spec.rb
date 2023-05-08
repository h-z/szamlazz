# frozen_string_literal: true

describe Szamlazz::InvoiceBuilder do
  let(:b) { described_class.new(client) }
  let(:client) { double(:client, user:, password:, token:, download_invoice:, response_version:, einvoice:) }
  let(:user) { "user" }
  let(:password) { "password" }
  let(:token) { "token" }
  let(:download_invoice) { false }
  let(:response_version) { 1 }
  let(:einvoice) { true }

  describe "#initialize" do
    subject { b }

    it { should be }
  end

  describe "#build_invoice" do
    subject { b.build_invoice(invoice) }

    let(:invoice) do
      Szamlazz::Invoice.new(payment_method:, currency:, language:, seller:, buyer:, items:,
                            prepayment_invoice:, external_key:, issue_date:, fulfillment_date:, due_date:,
                            exchange_bank:, exchange_rate:, order_id:, comment:, proform_invoice_id:, final_invoice:,
                            correction_invoice:, proform:, prefix:)
    end

    let(:payment_method) { "payment method" }
    let(:currency) { "HUF" }
    let(:language) { "hu" }
    let(:seller) { Szamlazz::Seller.new(bank_name:, bank_account:, email_address:, email_subject:, email_message:) }
    let(:buyer) do
      Szamlazz::Buyer.new(address:, post_address:, tax_number:, issuer_name:, identifier:, phone:, comment:,
                          send_email:, name:, email:)
    end
    let(:prepayment_invoice) { false }
    let(:external_key) { "KEY-1" }
    let(:issue_date) { "2020-10-10" }
    let(:fulfillment_date) { "2020-11-11" }
    let(:due_date) { "2020-12-12" }
    let(:exchange_bank) { "MNB" }
    let(:exchange_rate) { 1 }
    let(:order_id) { "O-1234" }
    let(:comment) { "My first comment" }
    let(:proform_invoice_id) { "PF-1234" }
    let(:final_invoice) { true }
    let(:correction_invoice) { false }
    let(:proform) { false }
    let(:prefix) { "ABC" }
    let(:bank_name) { "Big Bank" }
    let(:bank_account) { "12345678-12345678-12345678" }
    let(:email_address) { "seller@szamlazz.hu" }
    let(:email_subject) { "my first email subject" }
    let(:email_message) { "this is a message" }
    let(:address) { Szamlazz::Address.new(name: address_name, country:, zip:, city:, address: address_addr) }
    let(:post_address) do
      Szamlazz::Address.new(name: post_name, country: post_country, zip: post_zip, city: post_city, address: post_addr)
    end
    let(:tax_number) { "TX-1234" }
    let(:issuer_name) { "Issuer name" }
    let(:identifier) { "id-12345" }
    let(:phone) { "+3612345678" }
    let(:send_email) { false }
    let(:name) { "Buyer name" }
    let(:email) { "buyer@szamlazz.hu" }
    let(:address_name) { "Address name" }
    let(:country) { "HU" }
    let(:zip) { "1111" }
    let(:city) { "Mosonmagyaróvár" }
    let(:address_addr) { "Street utca 1." }
    let(:post_name) { "Address name" }
    let(:post_country) { "HU" }
    let(:post_zip) { "1111" }
    let(:post_city) { "Mosonmagyaróvár-Felső" }
    let(:post_addr) { "Street utca 1/a." }

    let(:items) { [item, other_item] }

    let(:item) { Szamlazz::Item.new(label:, quantity:, unit:, vat:, net_unit_price:, gross_unit_price:) }
    let(:label) { "Első tétel" }
    let(:quantity) { 12 }
    let(:unit) { "db" }
    let(:vat) { 45 }
    let(:net_unit_price) { 3400 }
    let(:gross_unit_price) { nil }

    let(:other_item) do
      Szamlazz::Item.new(
        label: "Második",
        quantity: 20,
        unit: "kg",
        vat: 15,
        net_unit_price: nil,
        gross_unit_price: 1000
      )
    end

    it { should be }

    it "should validate against schema" do
      expect(subject.to_xml).to pass_validation("#{File.dirname(__FILE__)}/schemas/invoice.xsd")
    end

    it "should have proper data" do
      doc = subject.doc
      doc.remove_namespaces!

      expect(doc.xpath("/xmlszamla/beallitasok/felhasznalo").text).to eq("user")
      expect(doc.xpath("/xmlszamla/beallitasok/jelszo").text).to eq("password")
      expect(doc.xpath("/xmlszamla/beallitasok/szamlaagentkulcs").text).to eq("token")
      expect(doc.xpath("/xmlszamla/beallitasok/eszamla").text).to eq("true")
      expect(doc.xpath("/xmlszamla/beallitasok/szamlaLetoltes").text).to eq("false")
      expect(doc.xpath("/xmlszamla/beallitasok/valaszVerzio").text).to eq("1")
      expect(doc.xpath("/xmlszamla/beallitasok/szamlaLetoltes").text).to eq("false")
      expect(doc.xpath("/xmlszamla/beallitasok/aggregator").text).to eq("")
      expect(doc.xpath("/xmlszamla/beallitasok/szamlaKulsoAzon").text).to eq("KEY-1")
      expect(doc.xpath("/xmlszamla/fejlec/keltDatum").text).to eq("2020-10-10")
      expect(doc.xpath("/xmlszamla/fejlec/teljesitesDatum").text).to eq("2020-11-11")
      expect(doc.xpath("/xmlszamla/fejlec/fizetesiHataridoDatum").text).to eq("2020-12-12")
      expect(doc.xpath("/xmlszamla/fejlec/fizmod").text).to eq("payment method")
      expect(doc.xpath("/xmlszamla/fejlec/penznem").text).to eq("HUF")
      expect(doc.xpath("/xmlszamla/fejlec/szamlaNyelve").text).to eq("hu")
      expect(doc.xpath("/xmlszamla/fejlec/megjegyzes").text).to eq("My first comment")
      expect(doc.xpath("/xmlszamla/fejlec/arfolyamBank").text).to eq("MNB")
      expect(doc.xpath("/xmlszamla/fejlec/arfolyam").text).to eq("1")
      expect(doc.xpath("/xmlszamla/fejlec/rendelesSzam").text).to eq("O-1234")
      expect(doc.xpath("/xmlszamla/fejlec/dijbekeroSzamlaszam").text).to eq("PF-1234")
      expect(doc.xpath("/xmlszamla/fejlec/elolegszamla").text).to eq("false")
      expect(doc.xpath("/xmlszamla/fejlec/vegszamla").text).to eq("true")
      expect(doc.xpath("/xmlszamla/fejlec/helyesbitoszamla").text).to eq("false")
      expect(doc.xpath("/xmlszamla/fejlec/dijbekero").text).to eq("false")
      expect(doc.xpath("/xmlszamla/fejlec/szamlaszamElotag").text).to eq("ABC")
      expect(doc.xpath("/xmlszamla/elado/bank").text).to eq("Big Bank")
      expect(doc.xpath("/xmlszamla/elado/bankszamlaszam").text).to eq("12345678-12345678-12345678")
      expect(doc.xpath("/xmlszamla/elado/emailReplyto").text).to eq("seller@szamlazz.hu")
      expect(doc.xpath("/xmlszamla/elado/emailTargy").text).to eq("my first email subject")
      expect(doc.xpath("/xmlszamla/elado/emailSzoveg").text).to eq("this is a message")
      expect(doc.xpath("/xmlszamla/vevo/nev").text).to eq("Buyer name")
      expect(doc.xpath("/xmlszamla/vevo/irsz").text).to eq("1111")
      expect(doc.xpath("/xmlszamla/vevo/telepules").text).to eq("Mosonmagyaróvár")
      expect(doc.xpath("/xmlszamla/vevo/cim").text).to eq("Street utca 1.")
      expect(doc.xpath("/xmlszamla/vevo/email").text).to eq("buyer@szamlazz.hu")
      expect(doc.xpath("/xmlszamla/vevo/sendEmail").text).to eq("false")
      expect(doc.xpath("/xmlszamla/vevo/adoszam").text).to eq("TX-1234")
      expect(doc.xpath("/xmlszamla/vevo/postazasiNev").text).to eq("Address name")
      expect(doc.xpath("/xmlszamla/vevo/postazasiIrsz").text).to eq("1111")
      expect(doc.xpath("/xmlszamla/vevo/postazasiTelepules").text).to eq("Mosonmagyaróvár-Felső")
      expect(doc.xpath("/xmlszamla/vevo/postazasiCim").text).to eq("Street utca 1/a.")
      expect(doc.xpath("/xmlszamla/vevo/azonosito").text).to eq("id-12345")
      expect(doc.xpath("/xmlszamla/vevo/telefonszam").text).to eq("+3612345678")
      expect(doc.xpath("/xmlszamla/vevo/megjegyzes").text).to eq("My first comment")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/megnevezes").text).to eq("Első tétel")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/mennyiseg").text).to eq("12")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/mennyisegiEgyseg").text).to eq("db")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/nettoEgysegar").text).to eq("3400")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/afakulcs").text).to eq("45")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/nettoErtek").text).to eq("40800")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/afaErtek").text).to eq("18360.0")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/bruttoErtek").text).to eq("59160.0")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[1]/megjegyzes").text).to eq("")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/megnevezes").text).to eq("Második")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/mennyiseg").text).to eq("20")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/mennyisegiEgyseg").text).to eq("kg")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/nettoEgysegar").text).to eq("869.57")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/afakulcs").text).to eq("15")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/nettoErtek").text).to eq("17391.3")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/afaErtek").text).to eq("2608.7")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/bruttoErtek").text).to eq("20000")
      expect(doc.xpath("/xmlszamla/tetelek/tetel[2]/megjegyzes").text).to eq("")
    end
  end
end
