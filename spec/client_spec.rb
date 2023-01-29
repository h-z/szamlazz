# frozen_string_literal: true

describe Szamlazz::Client do
  let(:client) { described_class.new(params) }

  describe "#initialize" do
    subject { client }
    let(:params) { { user:, password:, token: } }
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
end
