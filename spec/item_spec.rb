# frozen_string_literal: true

describe Szamlazz::Item do
  let(:item) { described_class.new(params) }

  describe "#initialize" do
    subject { item }
    let(:params) { { label:, quantity:, unit:, vat:, net_unit_price:, gross_unit_price:, comment: } }
    let(:label) { nil }
    let(:quantity) { 1 }
    let(:unit) { nil }
    let(:vat) { 25 }
    let(:net_unit_price) { 1 }
    let(:gross_unit_price) { 1 }
    let(:comment) { nil }

    context "without VAT" do
      let(:vat) { nil }
      it "should raise error " do
        expect { -> { subject }.to raise_error(ArgumentError) }
      end
    end

    context "without unit prices" do
      let(:net_unit_price) { nil }
      let(:gross_unit_price) { nil }
      it "should raise error " do
        expect { -> { subject }.to raise_error(ArgumentError) }
      end
    end

    context "with net unit price" do
      let(:net_unit_price) { 100 }
      let(:gross_unit_price) { nil }

      it { should be }
    end

    context "with gross unit price" do
      let(:net_unit_price) { nil }
      let(:gross_unit_price) { 100 }

      it { should be }
    end

    describe "values" do
      subject { item }
      # rubocop:disable Metrics/ParameterLists
      [
        [8, 1000, nil, 25, 8000, 2000, 10_000],
        [8, nil, 1000, 25, 6400, 1600, 8000],
        [10, 100, nil, 25, 1000, 250, 1250],
        [10, nil, 100, 25, 800, 200, 1000],
        [8.5, 1000, nil, 25, 8500, 2125, 10_625],
        [7.7, 100, nil, 17, 770, 130.9, 900.9]
      ].each do |q, nup, gup, v, nv, vv, gv|
        context "when q:#{q}, net unit price: #{nup}, gross unit price: #{gup}, vat: #{v}" do
          let(:quantity) { q }
          let(:net_unit_price) { nup }
          let(:gross_unit_price) { gup }
          let(:vat) { v }

          it "should have proper values" do
            expect(item.net_value).to eq nv
            expect(item.vat_value).to eq vv
            expect(item.gross_value).to eq gv
          end
        end
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
