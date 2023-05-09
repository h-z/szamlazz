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
  let(:invoice_id) { "1234" }
  let(:doc) { subject.doc }

  describe "#initialize" do
    subject { b }

    it { should be }
  end

  describe "#build_invoice" do
    subject { b.build_invoice(invoice) }
    let(:ns) { { "ns" => Szamlazz::InvoiceBuilder::XMLNS_INVOICE } }

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
      expect(subject.to_xml).to pass_validation("#{File.dirname(__FILE__)}/schemas/xmlszamla.xsd")
    end

    it "should have proper data" do
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:felhasznalo", ns).text).to eq("user")
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:jelszo", ns).text).to eq("password")
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:szamlaagentkulcs", ns).text).to eq("token")
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:eszamla", ns).text).to eq("true")
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:szamlaLetoltes", ns).text).to eq("false")
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:valaszVerzio", ns).text).to eq("2")
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:szamlaLetoltes", ns).text).to eq("false")
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:aggregator", ns).text).to eq("")
      expect(doc.xpath("/ns:xmlszamla/ns:beallitasok/ns:szamlaKulsoAzon", ns).text).to eq("KEY-1")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:keltDatum", ns).text).to eq("2020-10-10")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:teljesitesDatum", ns).text).to eq("2020-11-11")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:fizetesiHataridoDatum", ns).text).to eq("2020-12-12")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:fizmod", ns).text).to eq("payment method")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:penznem", ns).text).to eq("HUF")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:szamlaNyelve", ns).text).to eq("hu")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:megjegyzes", ns).text).to eq("My first comment")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:arfolyamBank", ns).text).to eq("MNB")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:arfolyam", ns).text).to eq("1")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:rendelesSzam", ns).text).to eq("O-1234")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:dijbekeroSzamlaszam", ns).text).to eq("PF-1234")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:elolegszamla", ns).text).to eq("false")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:vegszamla", ns).text).to eq("true")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:helyesbitoszamla", ns).text).to eq("false")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:dijbekero", ns).text).to eq("false")
      expect(doc.xpath("/ns:xmlszamla/ns:fejlec/ns:szamlaszamElotag", ns).text).to eq("ABC")
      expect(doc.xpath("/ns:xmlszamla/ns:elado/ns:bank", ns).text).to eq("Big Bank")
      expect(doc.xpath("/ns:xmlszamla/ns:elado/ns:bankszamlaszam", ns).text).to eq("12345678-12345678-12345678")
      expect(doc.xpath("/ns:xmlszamla/ns:elado/ns:emailReplyto", ns).text).to eq("seller@szamlazz.hu")
      expect(doc.xpath("/ns:xmlszamla/ns:elado/ns:emailTargy", ns).text).to eq("my first email subject")
      expect(doc.xpath("/ns:xmlszamla/ns:elado/ns:emailSzoveg", ns).text).to eq("this is a message")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:nev", ns).text).to eq("Buyer name")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:irsz", ns).text).to eq("1111")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:telepules", ns).text).to eq("Mosonmagyaróvár")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:cim", ns).text).to eq("Street utca 1.")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:email", ns).text).to eq("buyer@szamlazz.hu")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:sendEmail", ns).text).to eq("false")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:adoszam", ns).text).to eq("TX-1234")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:postazasiNev", ns).text).to eq("Address name")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:postazasiIrsz", ns).text).to eq("1111")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:postazasiTelepules", ns).text).to eq("Mosonmagyaróvár-Felső")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:postazasiCim", ns).text).to eq("Street utca 1/a.")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:azonosito", ns).text).to eq("id-12345")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:telefonszam", ns).text).to eq("+3612345678")
      expect(doc.xpath("/ns:xmlszamla/ns:vevo/ns:megjegyzes", ns).text).to eq("My first comment")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:megnevezes", ns).text).to eq("Első tétel")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:mennyiseg", ns).text).to eq("12")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:mennyisegiEgyseg", ns).text).to eq("db")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:nettoEgysegar", ns).text).to eq("3400")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:afakulcs", ns).text).to eq("45")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:nettoErtek", ns).text).to eq("40800")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:afaErtek", ns).text).to eq("18360.0")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:bruttoErtek", ns).text).to eq("59160.0")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[1]/ns:megjegyzes", ns).text).to eq("")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:megnevezes", ns).text).to eq("Második")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:mennyiseg", ns).text).to eq("20")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:mennyisegiEgyseg", ns).text).to eq("kg")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:nettoEgysegar", ns).text).to eq("869.57")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:afakulcs", ns).text).to eq("15")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:nettoErtek", ns).text).to eq("17391.3")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:afaErtek", ns).text).to eq("2608.7")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:bruttoErtek", ns).text).to eq("20000")
      expect(doc.xpath("/ns:xmlszamla/ns:tetelek/ns:tetel[2]/ns:megjegyzes", ns).text).to eq("")
    end
  end

  describe "#build_reverse_invoice" do
    subject { b.build_reverse_invoice(invoice_id) }
    let(:ns) { { "ns" => Szamlazz::InvoiceBuilder::XMLNS_REVERSE } }

    it { should be }

    it "should validate against schema" do
      expect(subject.to_xml).to pass_validation("#{File.dirname(__FILE__)}/schemas/xmlszamlast.xsd")
    end

    it "should have proper data" do
      expect(doc.xpath("/ns:xmlszamlast/ns:beallitasok/ns:felhasznalo", ns).text).to eq("user")
      expect(doc.xpath("/ns:xmlszamlast/ns:beallitasok/ns:jelszo", ns).text).to eq("password")
      expect(doc.xpath("/ns:xmlszamlast/ns:beallitasok/ns:szamlaagentkulcs", ns).text).to eq("token")
      expect(doc.xpath("/ns:xmlszamlast/ns:beallitasok/ns:eszamla", ns).text).to eq("true")
      expect(doc.xpath("/ns:xmlszamlast/ns:beallitasok/ns:szamlaLetoltes", ns).text).to eq("false")
      expect(doc.xpath("/ns:xmlszamlast/ns:beallitasok/ns:szamlaLetoltesPld", ns).text).to eq("1")
      expect(doc.xpath("/ns:xmlszamlast/ns:beallitasok/ns:valaszVerzio", ns).text).to eq("2")
      expect(doc.xpath("/ns:xmlszamlast/ns:beallitasok/ns:szamlaLetoltes", ns).text).to eq("false")
      expect(doc.xpath("/ns:xmlszamlast/ns:fejlec/ns:szamlaszam", ns).text).to eq("1234")
      expect(doc.xpath("/ns:xmlszamlast/ns:fejlec/ns:keltDatum", ns).text).to eq(Date.today.to_s)
    end
  end

  describe "#build_credit_invoice" do
    subject { b.build_credit_invoice(invoice_id, payments, additive) }
    let(:ns) { { "ns" => Szamlazz::InvoiceBuilder::XMLNS_CREDIT } }
    let(:payment) do
      Szamlazz::Payment.new(date: "2015-01-01",
                            title: "My first payment",
                            amount: 100,
                            description: "My first description")
    end
    let(:other_payment) do
      Szamlazz::Payment.new(date: "2015-01-02",
                            title: "My second(?) payment",
                            amount: 250,
                            description: "My second description")
    end
    let(:payments) { [payment, other_payment] }
    let(:additive) { false }

    it { should be }

    it "should validate against schema" do
      expect(subject.to_xml).to pass_validation("#{File.dirname(__FILE__)}/schemas/xmlszamlakifiz.xsd")
    end

    it "should have proper data" do
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:beallitasok/ns:felhasznalo", ns).text).to eq("user")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:beallitasok/ns:jelszo", ns).text).to eq("password")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:beallitasok/ns:szamlaagentkulcs", ns).text).to eq("token")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:beallitasok/ns:szamlaszam", ns).text).to eq("1234")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:beallitasok/ns:valaszVerzio", ns).text).to eq("2")

      expect(doc.xpath("/ns:xmlszamlakifiz/ns:beallitasok/ns:additiv", ns).text).to eq("false")

      expect(doc.xpath("count(/ns:xmlszamlakifiz/ns:kifizetes)", ns).to_i).to eq(2)
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:kifizetes[1]/ns:datum", ns).text).to eq("2015-01-01")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:kifizetes[1]/ns:jogcim", ns).text).to eq("My first payment")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:kifizetes[1]/ns:osszeg", ns).text).to eq("100")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:kifizetes[1]/ns:leiras", ns).text).to eq("My first description")

      expect(doc.xpath("/ns:xmlszamlakifiz/ns:kifizetes[2]/ns:datum", ns).text).to eq("2015-01-02")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:kifizetes[2]/ns:jogcim", ns).text).to eq("My second(?) payment")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:kifizetes[2]/ns:osszeg", ns).text).to eq("250")
      expect(doc.xpath("/ns:xmlszamlakifiz/ns:kifizetes[2]/ns:leiras", ns).text).to eq("My second description")
    end
  end

  describe "#build_download_invoice_pdf" do
    subject { b.build_download_invoice_pdf(invoice_id) }
    let(:ns) { { "ns" => Szamlazz::InvoiceBuilder::XMLNS_PDF } }

    it { should be }

    it "should validate against schema" do
      expect(subject.to_xml).to pass_validation("#{File.dirname(__FILE__)}/schemas/xmlszamlapdf.xsd")
    end

    it "should have proper data" do
      expect(doc.xpath("/ns:xmlszamlapdf/ns:felhasznalo", ns).text).to eq("user")
      expect(doc.xpath("/ns:xmlszamlapdf/ns:jelszo", ns).text).to eq("password")
      expect(doc.xpath("/ns:xmlszamlapdf/ns:szamlaagentkulcs", ns).text).to eq("token")
      expect(doc.xpath("/ns:xmlszamlapdf/ns:szamlaszam", ns).text).to eq("1234")
      expect(doc.xpath("/ns:xmlszamlapdf/ns:valaszVerzio", ns).text).to eq("2")
    end
  end

  describe "#build_download_invoice_xml" do
    subject { b.build_download_invoice_xml(invoice_id) }
    let(:ns) { { "ns" => Szamlazz::InvoiceBuilder::XMLNS_XML } }

    it { should be }

    it "should validate against schema" do
      expect(subject.to_xml).to pass_validation("#{File.dirname(__FILE__)}/schemas/xmlszamlaxml.xsd")
    end

    it "should have proper data" do
      expect(doc.xpath("/ns:xmlszamlaxml/ns:felhasznalo", ns).text).to eq("user")
      expect(doc.xpath("/ns:xmlszamlaxml/ns:jelszo", ns).text).to eq("password")
      expect(doc.xpath("/ns:xmlszamlaxml/ns:szamlaagentkulcs", ns).text).to eq("token")
      expect(doc.xpath("/ns:xmlszamlaxml/ns:szamlaszam", ns).text).to eq("1234")
    end
  end

  describe "#build_remove_proform_invoice_xml" do
    subject { b.build_remove_proform_invoice_xml(invoice_id, order_id) }
    let(:order_id) { nil }
    let(:ns) { { "ns" => Szamlazz::InvoiceBuilder::XMLNS_REMOVE_PROFORM } }

    it { should be }

    it "should validate against schema" do
      expect(subject.to_xml).to pass_validation("#{File.dirname(__FILE__)}/schemas/xmlszamladbkdel.xsd")
    end

    it "should have proper data" do
      expect(doc.xpath("/ns:xmlszamladbkdel/ns:beallitasok/ns:felhasznalo", ns).text).to eq("user")
      expect(doc.xpath("/ns:xmlszamladbkdel/ns:beallitasok/ns:jelszo", ns).text).to eq("password")
      expect(doc.xpath("/ns:xmlszamladbkdel/ns:beallitasok/ns:szamlaagentkulcs", ns).text).to eq("token")
      expect(doc.xpath("/ns:xmlszamladbkdel/ns:fejlec/ns:szamlaszam", ns).text).to eq("1234")
      expect(doc.xpath("/ns:xmlszamladbkdel/ns:fejlec/ns:rendelesszam", ns).text).to eq("")
    end

    context "when order id is set" do
      let(:order_id) { "654" }

      it "should have proper data" do
        expect(doc.xpath("/ns:xmlszamladbkdel/ns:beallitasok/ns:felhasznalo", ns).text).to eq("user")
        expect(doc.xpath("/ns:xmlszamladbkdel/ns:beallitasok/ns:jelszo", ns).text).to eq("password")
        expect(doc.xpath("/ns:xmlszamladbkdel/ns:beallitasok/ns:szamlaagentkulcs", ns).text).to eq("token")
        expect(doc.xpath("/ns:xmlszamladbkdel/ns:fejlec/ns:szamlaszam", ns).text).to eq("1234")
        expect(doc.xpath("/ns:xmlszamladbkdel/ns:fejlec/ns:rendelesszam", ns).text).to eq("654")
      end
    end
  end
end
