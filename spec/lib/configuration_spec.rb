require 'spec_helper'

describe XmlFu::Configuration do
  subject { XmlFu::Configuration }

  it "should have ::ALGORITHMS" do
    lambda { subject::ALGORITHMS }.should_not raise_exception
    subject::ALGORITHMS.should_not be_nil
  end

  describe "instance" do
    subject { XmlFu::Configuration.new }

    [ :symbol_conversion_algorithm,
      :symbol_conversion_algorithm=,
      :fail_on_invalid_construct,
      :include_xml_declaration
    ].each do |m|
      it "should respond_to '#{m}'" do
        subject.should respond_to(m)
      end
    end
  end#instance
end
