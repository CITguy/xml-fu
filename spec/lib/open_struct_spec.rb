require 'spec_helper'
require 'ostruct'

describe XmlFu::OpenStruct do
  let(:klass) { XmlFu::OpenStruct }

  describe ".to_xml" do
    subject { OpenStruct.new({:foo => "bar"}) }

    it "should result in correct output" do
      klass.to_xml(subject).should == "<foo>bar</foo>"
    end

    context "with complex nesting" do
      subject do
        OpenStruct.new({
          :foo => [
            OpenStruct.new({ :bar => "bang" }),
            { :bang => :biz },
            { "number*" => [
              { "@name" => "pi", "=" => 3.14159 }
            ]}
          ]
        })
      end

      # NOTE: (TL;DR) Cannot guarantee attribute order, can only guarantee attribute presence
      #
      # Due to the way XML::Builder iterates over attributes, the order of the attributes
      # cannot be guaranteed. This is because of the way that ruby stores and iterates
      # over a Hash, and it is different depending on the version of Ruby being used.
      it "should result in correct output" do
        klass.to_xml(subject).should == '<foo><bar>bang</bar><bang>biz</bang><number name="pi">3.14159</number></foo>'
      end
    end
  end#.to_xml
end
