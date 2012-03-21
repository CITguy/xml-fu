require 'spec_helper'

describe XmlFu::Markup do

  it "should return a Builder::XmlMarkup object when instantiated" do
    Builder::XmlMarkup.should === XmlFu::Markup.new
  end
end
