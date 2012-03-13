require 'spec_helper'

describe XmlFu::Node do

  describe "setting instance variables" do
    it "should correctly remove special characters from a name" do
      node = XmlFu::Node.new("foo/", "something")
      node.name.should == "foo"

      node = XmlFu::Node.new("foo*", "something")
      node.name.should == "foo"

      node = XmlFu::Node.new("foo!", "something")
      node.name.should == "foo"
    end

    it "should set self-closing with special name character" do
      node = XmlFu::Node.new("foo/", "something")
      node.self_closing.should == true
    end

    it "should set escape_xml with special name character" do
      node = XmlFu::Node.new("foo!", "something")
      node.escape_xml.should == false
    end

    it "should set attributes with a hash" do
      node = XmlFu::Node.new("foo", "bar", {:this => "that"})
      node.attributes.should == {:this => "that"}

      lambda { node.attributes = "foo" }.should raise_error(XmlFu::Node::InvalidAttributesException)
    end

    it "should be able to set a nil value" do
      node = XmlFu::Node.new("foo", nil)
      node.value.should == nil
    end

    it "should format a Data/Time value to acceptable string value" do
      formatted_regex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/

      node = XmlFu::Node.new("now", Time.now)
      node.value.should match formatted_regex

      node = XmlFu::Node.new("today", Date.today)
      node.value.should match formatted_regex
    end

    it "should properly convert names without proper namespacing" do
      node = XmlFu::Node.new(":foo", "bar")
      node.name.should == "foo"
    end

    it "should properly preserve namespaceds names" do
      node = XmlFu::Node.new("foo:bar", "biz")
      node.name.should == "foo:bar"
    end
  end

  describe "to_xml" do
    
    describe "should return self-closing nil XML node for nil value" do

      it "provided ANY non-blank name" do
        nil_foo = "<foo xsi:nil=\"true\"/>"
        node = XmlFu::Node.new("foo", nil)
        node.to_xml.should == nil_foo

        node = XmlFu::Node.new("foo!", nil)
        node.to_xml.should == nil_foo

        node = XmlFu::Node.new("foo*", nil)
        node.to_xml.should == nil_foo
      end

      it "with additional attributes provided" do
        node = XmlFu::Node.new("foo", nil, {:this => "that"})
        node.to_xml.should == "<foo this=\"that\" xsi:nil=\"true\"/>"
      end

    end

    it "should escape values by default" do
      node = XmlFu::Node.new("foo", "<bar/>")
      node.to_xml.should == "<foo>&lt;bar/&gt;</foo>"
    end

    it "should not escape values when provided with a special name" do
      node = XmlFu::Node.new("foo!", "<bar/>")
      node.to_xml.should == "<foo><bar/></foo>"
    end

    it "should ignore starred key (key*) for simple values" do
      node = XmlFu::Node.new("foo*", "bar")
      node.to_xml.should == "<foo>bar</foo>"

      node = XmlFu::Node.new("pi*", 3.14159)
      node.to_xml.should == "<pi>3.14159</pi>"
    end

    describe "when name denotes a self-closing XML node" do
      it "should ignore tag content/value if it isn't a hash" do
        node = XmlFu::Node.new("foo/", nil)
        node.to_xml.should == "<foo/>"

        node = XmlFu::Node.new("foo/", "bar")
        node.to_xml.should == "<foo/>"
      end
    end
  end

end
