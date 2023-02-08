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
    let(:items) { [] }
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
    let(:final_invoice) { "final" }
    let(:correction_invoice) { "I-1233" }
    let(:proform) { "proform" }
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
    let(:address_addr) { "Street utca 1. " }
    let(:post_name) { "Address name" }
    let(:post_country) { "HU" }
    let(:post_zip) { "1111" }
    let(:post_city) { "Mosonmagyaróvár" }
    let(:post_addr) { "Street utca 1. " }

    it { should be }
  end
end
