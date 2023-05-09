# frozen_string_literal: true

require "spec_helper"

describe Szamlazz::Client do
  let(:client) { described_class.new(params) }
  let(:params) { { user:, password:, token: } }
  let(:invoice) { instance_double(Szamlazz::Invoice) }
  let(:invoice_id) { "XX-2023-1" }
  let(:password) { "password" }
  let(:user) { "user" }
  let(:token) { nil }
  let(:builder) do
    double(Szamlazz::InvoiceBuilder,
           build_invoice: xml,
           build_reverse_invoice: xml,
           build_credit_invoice: xml,
           build_download_invoice_pdf: xml,
           build_download_invoice_xml: xml,
           build_remove_proform_invoice_xml: xml)
  end
  let(:xml) { double(:xml, to_xml: "xml") }
  let(:response) { double(:response, body:) }
  let(:body) { "<valasz><sikeres>true</sikeres></valasz>" }

  before do
    allow(Szamlazz::InvoiceBuilder).to receive(:new).and_return(builder)
    allow(HTTP).to receive(:post).and_return(response)
  end

  describe "#initialize" do
    subject { client }
    let(:user) { nil }
    let(:password) { nil }
    let(:token) { nil }

    it "should raise error without credentials" do
      expect { -> { subject }.to raise_error(ArgumentError) }
    end

    context "with user" do
      let(:user) { "user" }
      context "with password" do
        let(:password) { "password" }

        it { should be }
      end

      it "should raise error without credentials" do
        expect { -> { subject }.to raise_error(ArgumentError) }
      end
    end

    context "with token" do
      let(:token) { "my first token" }

      it { should be }
    end
  end

  describe "#issue_invoice" do
    subject { client.issue_invoice(invoice) }

    it "should return response" do
      expect(subject).to be_a(Szamlazz::Response)
    end
  end

  describe "#reverse_invoice" do
    subject { client.reverse_invoice(invoice_id) }

    it "should return response" do
      expect(subject).to be_a(Szamlazz::Response)
    end
  end

  describe "#credit_invoice" do
    subject { client.credit_invoice(invoice_id, [], true) }

    it "should return response" do
      expect(subject).to be_a(Szamlazz::Response)
    end
  end

  describe "#download_invoice_pdf" do
    subject { client.download_invoice_pdf(invoice_id) }

    it "should return response" do
      expect(subject).to be_a(Szamlazz::Response)
    end
  end

  describe "#download_invoice_xml" do
    subject { client.download_invoice_xml(invoice_id) }

    it "should return response" do
      expect(subject).to be_a(Nokogiri::XML::Document)
    end
  end

  describe "#remove_proform_invoice" do
    subject { client.remove_proform_invoice(invoice_id) }

    it "should return response" do
      expect(subject).to be_a(Szamlazz::Response)
    end
  end
end
