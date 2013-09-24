require 'spec_helper'

describe XmlFu do
  describe ".xml" do
    context "(default configuration)" do
      context "with an unsupported construct as argument" do
        it "should return nil" do
          XmlFu.xml(1).should == nil
          XmlFu.xml(nil).should == nil
          XmlFu.xml(Object.new).should == nil
        end
      end

      it "translates a given Hash to XML" do
        XmlFu.xml({:id => 1}).should == "<id>1</id>"
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
        expected = '<SecretAgents><agent name="Alec Trevelyan"/><agent name="James Bond"/></SecretAgents>'
        XmlFu.xml(hash).should == expected
      end

      it "should return correct value for nested collection of hashes" do
        hash = {
          "foo*" => [
            {"@bar" => "biz"},
            {"@biz" => "bang"}
          ]
        }
        XmlFu.xml(hash).should == '<foo bar="biz"></foo><foo biz="bang"></foo>'
      end

      it "should return list of self-closing nodes" do
        hash = {
          "foo/*" => [
            {"@bar" => "biz"},
            {"@biz" => "bang"}
          ]
        }
        XmlFu.xml(hash).should == '<foo bar="biz"/><foo biz="bang"/>'
      end

      it "should ignore nested values for content array" do
        output = XmlFu.xml("foo/" => [{:bar => "biz"}, {:bar => "biz"}])
        output.should == "<foo/>"
      end

      it "should ignore nested keys if they aren't attributes" do
        output = XmlFu.xml("foo/" => {"bar" => "biz"})
        output.should == "<foo/>"

        output = XmlFu.xml("foo/" => {"@id" => "0"})
        output.should == '<foo id="0"/>'
      end
    end#default configuration

    context "with 'fail_on_invalid_construct' enabled" do
      before(:each) do
        XmlFu.configure do |config|
          config.fail_on_invalid_construct = true
        end
      end

      context "with an unsupported construct as argument" do
        it "should raise an ArgumentError exception" do
          lambda { XmlFu.xml(1) }.should raise_exception
          lambda { XmlFu.xml(nil) }.should raise_exception
          lambda { XmlFu.xml(Object.new) }.should raise_exception
        end
      end
    end#fail_on_invalid_construct enabled

    context "with 'include_xml_declaration" do
      context "set TRUE" do
        before(:each) do
          XmlFu.configure do |config|
            config.include_xml_declaration = true
          end
        end

        it "should ALWAYS output the xml declaration" do
          XmlFu.xml({:foo => "bar"}).should == '<?xml version="1.0" encoding="UTF-8"?><foo>bar</foo>'
          XmlFu.xml({:foo => "bar"}, {:instruct => false}).should == '<?xml version="1.0" encoding="UTF-8"?><foo>bar</foo>'
          XmlFu.xml({:foo => "bar"}, {:instruct => true}).should == '<?xml version="1.0" encoding="UTF-8"?><foo>bar</foo>'
        end
      end#enabled

      context "set FALSE" do
        before(:each) do
          XmlFu.configure do |config|
            config.include_xml_declaration = false
          end
        end

        it "should NEVER output the xml declaration" do
          XmlFu.xml({:foo => "bar"}).should == '<foo>bar</foo>'
          XmlFu.xml({:foo => "bar"}, {:instruct => false}).should == '<foo>bar</foo>'
          XmlFu.xml({:foo => "bar"}, {:instruct => true}).should == '<foo>bar</foo>'
        end
      end#enabled

      context "set NIL" do
        before(:each) do
          XmlFu.configure do |config|
            config.include_xml_declaration = nil
          end
        end

        it "should output if option says so" do
          XmlFu.xml({:foo => "bar"}).should == '<foo>bar</foo>'
          XmlFu.xml({:foo => "bar"}, {:instruct => false}).should == '<foo>bar</foo>'
          XmlFu.xml({:foo => "bar"}, {:instruct => true}).should == '<?xml version="1.0" encoding="UTF-8"?><foo>bar</foo>'
        end
      end
    end
  end#.xml

  describe ".recognized_object?" do
    describe "should be true" do
      it { XmlFu.recognized_object?(Hash.new).should be_true }
      it { XmlFu.recognized_object?(Array.new).should be_true }
      it { XmlFu.recognized_object?(OpenStruct.new).should be_true }

      context "if object responds to :to_xml" do
        subject do
          obj = Object.new
          def obj.to_xml; end
          obj
        end
        it { XmlFu.recognized_object?(subject).should be_true }
      end
    end#should be true

    describe "should be false" do
      it { XmlFu.recognized_object?(1).should_not be_true }
      it { XmlFu.recognized_object?("foobar").should_not be_true }
      it { XmlFu.recognized_object?(1.23).should_not be_true }
      context "if object does not respond to :to_xml" do
        it { XmlFu.recognized_object?(Object.new).should_not be_true }
      end
    end#should be false
  end#.recognized_object?

  describe ".configure" do
    context "yielded value" do
      it "should be the same object as .config()" do
        yielded = nil
        XmlFu.configure { |c| yielded = c }
        yielded.should == XmlFu.config
      end
    end#yielded value
  end#.configure

  describe ".config" do
    subject { XmlFu.config }
    it "should be a XmlFu::Configuration object" do
      subject.should be_a_kind_of(XmlFu::Configuration)
    end
  end#.config

end
