# frozen_string_literal: true

describe Szamlazz::Response do
  let(:response) { described_class.new(body) }

  describe "#initialize" do
    subject { response }
    let(:body) { nil }
  end
end
