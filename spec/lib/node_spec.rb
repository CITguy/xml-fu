require 'spec_helper'

describe XmlFu::Node do
  it "should remove special characters from name no matter how many times they appear at the end" do
    node = XmlFu::Node.new("foo/*!", 'something')
    node.name.should == 'foo'

    node = XmlFu::Node.new("foo/*/**/!!!", 'something')
    node.name.should == 'foo'
  end

  describe "with hash as value" do
    it "should store the value as a hash" do
      node = XmlFu::Node.new("foo", {"bar" => "biz"})
      node.value.class.should == Hash
    end

    it "should create nested nodes with simple hash" do
      node = XmlFu::Node.new("foo", {"bar" => "biz"})
      node.to_xml.should == "<foo><bar>biz</bar></foo>"
    end
  end

  describe "with array as value" do
    it "should store the value as an array" do
      node = XmlFu::Node.new("foo", ["bar", "biz"])
      node.value.class.should == Array
    end

    it "should create nodes with simple collection array" do
      node = XmlFu::Node.new("foo*", ["bar", "biz"])
      node.to_xml.should == "<foo>bar</foo><foo>biz</foo>"
    end

    it "should create nodes with simple contents array" do
      node = XmlFu::Node.new("foo*", [{:bar => "biz"}])
      node.to_xml.should == "<foo><bar>biz</bar></foo>"
    end
  end

  describe "setting instance variables" do
    it "should correctly remove special characters from a name" do
      node = XmlFu::Node.new("foo/", "something")
      node.name.should == "foo"

      node = XmlFu::Node.new("foo*", "something")
      node.name.should == "foo"

      node = XmlFu::Node.new("foo!", "something")
      node.name.should == "foo"

      node = XmlFu::Node.new("foo:bar!", "something")
      node.name.should == "foo:bar"
    end

    it "should set self-closing with special name character" do
      node = XmlFu::Node.new("foo/", "something")
      node.self_closing.should == true
    end

    it "should set escape_xml with special name character" do
      node = XmlFu::Node.new("foo!", "something")
      node.escape_xml.should == false
    end

    it "should set content_type with special name character" do
      node = XmlFu::Node.new("foo", "something")
      node.content_type.should == "container"

      node = XmlFu::Node.new("foo*", "something")
      node.content_type.should == "collection"
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

      node = XmlFu::Node.new("foo:bar!", "biz")
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
        # Depending on the version of ruby, one of 
        # these two acceptible values would be returned
        [ "<foo this=\"that\" xsi:nil=\"true\"/>", 
          "<foo xsi:nil=\"true\" this=\"that\"/>"
        ].should include(node.to_xml)
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
