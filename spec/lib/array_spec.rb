require 'spec_helper'

describe XmlFu::Array do

  describe ".to_xml" do
    #after do
    #  XmlFu.infer_simple_value_nodes = false
    #end

    #it "should infer simple value type nodes with configuration turned on" do
    #  mixed_hash = {
    #    "foo" => [
    #      {:bar => "biz"}, 
    #      nil, 
    #      true, 
    #      false, 
    #      3.14, 
    #      "simple string", 
    #      ["another","array","of","values"]
    #    ]
    #  }
    #  XmlFu.infer_simple_value_nodes = true
    #  XmlFu.xml(mixed_hash).should_not == "<foo><bar>biz</bar></foo>"
    #
    #  XmlFu.infer_simple_value_nodes = false
    #  XmlFu.xml(mixed_hash).should == "<foo><bar>biz</bar></foo>"
    #
    #  XmlFu.infer_simple_value_nodes = false
    #end

    it "should flatten nested arrays properly" do
      hash = { 
        :foo => [
          [{"a/" => nil}, {"b/" => nil}],
          {"c/" => nil},
          [
            [{"d/" => nil}, {"e/" => nil}],
            {"f/" => nil}
          ]
        ]
      }
      expected = "<foo><a/><b/><c/><d/><e/><f/></foo>"
      XmlFu.xml(hash).should == expected
    end

    describe "creating siblings with special key character (*)" do
      it "should create siblings with special key character" do
        hash = { "person*" => ["Bob", "Sheila"] }
        XmlFu.xml(hash).should == "<person>Bob</person><person>Sheila</person>"
      end

      it "should create siblings with mixed attributes" do
        hash = { 
          "person*" => { 
            "@foo" => "bar", 
            "=" => ["Bob", "Sheila"] 
          }
        }
        XmlFu.xml(hash).should == "<person foo=\"bar\">Bob</person><person foo=\"bar\">Sheila</person>"
      end

      it "should create siblings with complex mixed attributes" do
        hash = { 
          "person*" => { 
            "@foo" => "bar", 
            "=" => [
              {"@foo" => "nope", "=" => "Bob"}, 
              "Sheila"
            ] 
          }
        }
        XmlFu.xml(hash).should == "<person foo=\"nope\">Bob</person><person foo=\"bar\">Sheila</person>"
      end
    end

  end
end
