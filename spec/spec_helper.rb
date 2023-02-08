# frozen_string_literal: true

require "szamlazz"

class HaveXpath
  def initialize(xpath)
    @xpath = xpath
  end

  def matches?(str)
    @str = str
    xml_document.xpath(@xpath).any?
  end

  def failure_message
    "Expected xpath #{@xpath.inspect} to match in:\n" + pretty_printed_xml
  end

  def failure_message_when_negated
    "Expected xpath #{@xpath.inspect} not to match in:\n" + pretty_printed_xml
  end

  private

  def pretty_printed_xml
    xml_document.to_xml(indent: 2)
  end

  def xml_document
    @xml_document ||= Nokogiri::XML(@str)
  end
end

def have_xpath(*args)
  HaveXpath.new(*args)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
