require 'spec_helper'

describe XmlFu::Hash do

  describe ".to_xml" do
    it "for a simple Hash" do
      XmlFu::Hash.to_xml(:some => "body").should == "<some>body</some>"
    end

    it "for a nested Hash" do
      XmlFu::Hash.to_xml(:foo => {:bar => "biz" }).should == "<foo><bar>biz</bar></foo>"
    end

    it "for a hash with multiple keys" do
      XmlFu::Hash.to_xml(:first => "myself", :second => "the world").should include(
        "<first>myself</first>",
        "<second>the world</second>"
      )
    end


    describe "for a hash value with '=' key defined" do
      it "should ignore '=' for self-closing tag" do
        hash = {"foo/" => {"@id" => "1", "=" => "PEEKABOO"}}
        XmlFu.xml(hash).should == "<foo id=\"1\"/>"
      end

      it "should set additional content using '=' key" do
        hash = {:foo => {"@id" => "1", "=" => "Hello"}}
        XmlFu.xml(hash).should == "<foo id=\"1\">Hello</foo>"
      end
    end

    describe "with a key that will contain multiple nodes" do
      describe "when key explicitly denotes value is a collection" do
        hash = { "foo*" => ["bar", "biz"] }
        XmlFu::Hash.to_xml(hash).should == "<foo>bar</foo><foo>biz</foo>"
      end

      describe "when key denotes value contains children" do
        it "for array consisting entirely of simple values" do
          XmlFu::Hash.to_xml(:foo => ["bar", "biz"]).should == "<foo></foo>"
        end

        it "for array containing mix of simple and complex values" do
          XmlFu::Hash.to_xml(:foo => ["bar", {:biz => "bang"}]).should == "<foo><biz>bang</biz></foo>"
        end

        it "for array containing complex values" do
          hash1 = {:foo => "bar"}
          hash2 = {:bar => "biz"}
          XmlFu::Hash.to_xml(:lol => [hash1, hash2]).should == "<lol><foo>bar</foo><bar>biz</bar></lol>"
        end

        it "for array containing nil values" do
          XmlFu::Hash.to_xml(:foo => [nil, {:bar => "biz"}]).should == "<foo><bar>biz</bar></foo>"
        end
      end
    end
  end
end
