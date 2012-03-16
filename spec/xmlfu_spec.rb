require 'spec_helper'

describe XmlFu do
  describe ".xml" do
    it "should return nil for value that isn't a Hash or Array" do
      XmlFu.xml(1).should == nil
      XmlFu.xml(nil).should == nil
      XmlFu.xml(Object.new).should == nil
    end

    it "translates a given Hash to XML" do
      XmlFu.xml( :id => 1 ).should == "<id>1</id>"
    end

    it "doesn't modify the input hash" do
      the_hash = {
        :person => {
          "@id" => "007",
          :first_name => "James",
          :last_name => "Bond"
        }
      }
      original_hash = the_hash.dup

      XmlFu.xml(the_hash)
      original_hash.should == the_hash
    end

    it "should return correct value based on nested array of hashes" do
      hash = {
        "SecretAgents" => [
          {"agent/" => {"@name"=>"Alec Trevelyan"}}, 
          {"agent/" => {"@name"=>"James Bond"}}
        ]
      }
      expected = "<SecretAgents><agent name=\"Alec Trevelyan\"/><agent name=\"James Bond\"/></SecretAgents>" 
      XmlFu.xml(hash).should == expected
    end

    it "should return correct value for nested collection of hashes" do
      hash = {
        "foo*" => [
          {"@bar" => "biz"},
          {"@biz" => "bang"}
        ]
      }
      XmlFu.xml(hash).should == "<foo bar=\"biz\"></foo><foo biz=\"bang\"></foo>"
    end

    it "should return list of self-closing nodes" do
      hash = {
        "foo/*" => [
          {"@bar" => "biz"},
          {"@biz" => "bang"}
        ]
      }
      XmlFu.xml(hash).should == "<foo bar=\"biz\"/><foo biz=\"bang\"/>"
    end

    it "should ignore nested values for content array" do
      output = XmlFu.xml("foo/" => [{:bar => "biz"}, {:bar => "biz"}])
      output.should == "<foo/>"
    end

    it "should ignore nested keys if they aren't attributes" do
      output = XmlFu.xml("foo/" => {"bar" => "biz"})
      output.should == "<foo/>"

      output = XmlFu.xml("foo/" => {"@id" => "0"})
      output.should == "<foo id=\"0\"/>"
    end
  end

  describe "configure" do
    it "yields the XmlFu module" do
      XmlFu.configure do |xf|
        xf.should respond_to(:infer_simple_value_nodes)
      end
    end
  end

  it "should set XmlFu Module variable 'infer_simple_value_nodes'" do
    XmlFu.infer_simple_value_nodes.should == false
    XmlFu.infer_simple_value_nodes = true
    XmlFu.infer_simple_value_nodes.should == true
    XmlFu.infer_simple_value_nodes = false
    XmlFu.infer_simple_value_nodes.should == false
  end
end
