require 'spec_helper'

describe XmlFu do
  after(:each) do
    XmlFu.config.symbol_conversion_algorithm = :default
  end

  describe "with default symbol conversion algorithm" do
    before(:each) do
      XmlFu.config.symbol_conversion_algorithm = :default
    end

    {
      :FooBar => "fooBar",
      :foobar => "foobar"
    }.each do |k,v|
      it "should convert :#{k} to #{v}" do
        doc = XmlFu.xml( k => "")
        doc.should == "<#{v}></#{v}>"
      end
    end
  end#default (:lower_camelcase)


  describe "with built-in :camelcase algorithm" do
    before(:each) do
      XmlFu.config.symbol_conversion_algorithm = :camelcase
    end

    {
      :foo_bar => "FooBar",
      :foobar => "Foobar"
    }.each do |k,v|
      it "should convert :#{k} to #{v}" do
        doc = XmlFu.xml( k => "")
        doc.should == "<#{v}></#{v}>"
      end
    end
  end#:camelcase


  describe "with built-in :downcase algorithm" do
    before(:each) do
      XmlFu.config.symbol_conversion_algorithm = :downcase
    end

    {
      :FOO_BAR => "foo_bar",
      :FooBar => "foobar"
    }.each do |k,v|
      it "should convert :#{k} to #{v}" do
        doc = XmlFu.xml( k => "")
        doc.should == "<#{v}></#{v}>"
      end
    end
  end#:downcase


  describe "with built-in :upcase algorithm" do
    before(:each) do
      XmlFu.config.symbol_conversion_algorithm = :upcase
    end

    {
      :foo_bar => "FOO_BAR",
      :FooBar => "FOOBAR"
    }.each do |k,v|
      it "should convert :#{k} to #{v}" do
        doc = XmlFu.xml( k => "")
        doc.should == "<#{v}></#{v}>"
      end
    end
  end#:upcase
end#XmlFu
