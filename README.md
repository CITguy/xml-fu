# XmlFu [![Build Status](http://travis-ci.org/CITguy/xml-fu.png)](http://travis-ci.org/CITguy/xml-fu)

Convert Ruby Hashes to XML

A hash is meant to be a structured set of data. So is XML. The two are very similar in that they have
the capability of nesting information within a tree structure. With XML you have nodes. With Hashes, you
have key/value pairs. The value of an XML node is referenced by its parent's name. A hash value is referenced
by its key. This basic lesson tells the majority of what you need to know about creating XML via Hashes in
Ruby using the XmlFu gem.


## Installation

Add this line to your application's Gemfile:

    gem 'xml-fu'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xml-fu


## Hash Keys

Hash keys are translated into XML nodes (whether it be a document node or attribute node).


### Key Translation

With Ruby, a hash key may be a string or a symbol.  **Strings will be preserved** as they may
contain node namespacing ("foo:Bar" would need preserved rather than converted).  Symbols will
be converted into an XML safe name by lower camel-casing them. So :foo\_bar will become "fooBar".
You may change the conversion algorithm to your liking by setting the
XmlFu.symbol\_conversion\_algorithm to a lambda or proc of your liking.


#### Built-In Algorithms

For a complete list, reference XmlFu::Node::ALGORITHMS

* :camelcase
* :downcase
* :lower\_camelcase **(default)**
* :none (result of :sym.to\_s)
* :upcase

```ruby
# Default Algorithm (:lower_camelcase)
XmlFu.xml( :FooBar => "bang" ) #=> "<fooBar>bang</fooBar>"
XmlFu.xml( :foo_bar => "bang" ) #=> "<fooBar>bang</fooBar>"


# Built-in Algorithms (:camelcase)
XmlFu.symbol_conversion_algorithm = :camelcase
XmlFu.xml( :Foo_Bar => "bang" ) #=> "<FooBar>bang</FooBar>"
XmlFu.xml( :foo_bar => "bang" ) #=> "<FooBar>bang</FooBar>"


# Built-in Algorithms (:downcase)
XmlFu.symbol_conversion_algorithm = :downcase
XmlFu.xml( :foo_bar => "bang" ) #=> "<foo_bar>bang</foo_bar>"
XmlFu.xml( :Foo_Bar => "bang" ) #=> "<foo_bar>bang</foo_bar>"
XmlFu.xml( :FOO => "bar" ) #=> "<foo>bar</foo>"


# Built-in Algorithms (:upcase)
XmlFu.symbol_conversion_algorithm = :upcase
XmlFu.xml( :foo_bar => "bang" ) #=> "<FOO_BAR>bang</FOO_BAR>"
XmlFu.xml( :Foo_Bar => "bang" ) #=> "<FOO_BAR>bang</FOO_BAR>"
XmlFu.xml( :foo => "bar" ) #=> "<FOO>bar</FOO>"


# Custom Algorithm
XmlFu.symbol_conversion_algorithm = lambda {|sym| sym.do_something_special }
```

### Types of Nodes

Because there are multiple types of XML nodes, there are also multiple types of keys to denote them.


#### Self-Closing Nodes (key/)

By default, XmlFu assumes that all XML nodes will contain closing tags. However, if you want to explicitly
create a self-closing node, use the following syntax when you define the key.

``` ruby
XmlFu.xml("foo/" => "bar") #=> <foo/>
```

One thing to take note of this syntax is that XmlFu will ignore ANY value you throw at it if the key syntax
denotes a self-closing tag. This is because a self-closing tag cannot have any contents (hence the use for
a self-closing tag).


#### Unescaped Content Nodes (key!)

By default, if you pass a pure string as a value, special characters will be escaped to keep the XML compliant.
If you know that the string is valid XML and can be trusted, you can add the exclamation point to the end of
the key name to denote that XmlFu should NOT escape special characters in the value.

```ruby
# Default Functionality (Escaped Characters)
XmlFu.xml("foo" => "<bar/>") #=> "<foo>&lt;bar/&gt;</foo>"

# Unescaped Characters
XmlFu.xml("foo!" => "<bar/>") #=> "<foo><bar/></foo>"
```


#### Attribute Node (@key)

Yes, the attributes of an XML node are nodes themselves, so we need a way of defining them. Since XPath syntax
uses @ to denote an attribute, so does XmlFu.

``` ruby
XmlFu.xml(:agent => {
  "@id" => "007",
  "FirstName" => "James",
  "LastName" => "Bond"
})
#=> <agent id="007"><FirstName>James</FirstName><LastName>Bond</LastName></agent>
```


## Hash Values

The value in a key/value pair describes the key/node. Different value types determine the extent of this description.


### Simple Values

Simple value types describe the contents of the XML node.


#### Strings

``` ruby
XmlFu.xml( :foo => "bar" ) #=> "<foo>bar</foo>"
XmlFu.xml( "foo" => "bar" ) #=> "<foo>bar</foo>"
```


#### Numbers

``` ruby
XmlFu.xml( :foo => 0 ) #=> "<foo>0</foo>"
XmlFu.xml( :pi => 3.14159 ) #=> "<pi>3.14159</pi>"
```


#### Nil

``` ruby
XmlFu.xml( :foo => nil ) #=> "<foo xsi:nil=\"true\"/>"
```


### Hashes

Hash are parsed for their translated values prior to returning a XmlFu value.

```ruby
XmlFu.xml(:foo => {:bar => {:biz => "bang"} })
#=> "<foo><bar><biz>bang</biz></bar></foo>"
```

#### Content in Hash (=)

Should you require setting node attributes as well as setting the value of the XML node, you may use the "="
key in a nested hash to denote explicit content.

```ruby
XmlFu.xml(:agent => {"@id" => "007", "=" => "James Bond"})
#=> "<agent id=\"007\">James Bond</agent>"
```

This key will not get around the self-closing node rule. The only nodes that will be used in this case will be
attribute nodes and additional content will be ignored.

```ruby
XmlFu.xml("foo/" => {"@id" => "123", "=" => "You can't see me."})
#=> "<foo id=\"123\"/>"
```


### Arrays

Since the value in a key/value pair is (for the most part) used as the contents of a key/node, there are some
assumptions that XmlFu makes when dealing with Array values.

* For a typical key, the contents of the array are considered to be nodes to be contained within the <key> node.


#### Array of Hashes

``` ruby
XmlFu.xml( "SecretAgents" => [
  { "agent/" => { "@id"=>"006", "@name"=>"Alec Trevelyan" } },
  { "agent/" => { "@id"=>"007", "@name"=>"James Bond" } }
])
#=> "<SecretAgents><agent name=\"Alec Trevelyan\" id=\"006\"/><agent name=\"James Bond\" id=\"007\"/></SecretAgents>"
```


#### Alternate Array of Hashes (key\*)

There comes a time that you may want to declare the contents of an array as a collection of items denoted by the
key name. Using the asterisk (also known for multiplication --- hence multiple keys) we denote that we want a
collection of &lt;key&gt; nodes.

```ruby
XmlFu.xml( "person*" => ["Bob", "Sheila"] )
#=> "<person>Bob</person><person>Sheila</person>"
```

In this case, the value of "person*" is an array of two names. These names are to be the contents of multiple
&lt;person&gt; nodes and the result is a set of sibling XML nodes with no parent.

How about a more complex example:

```ruby
XmlFu.xml(
  "person*" => {
    "@foo" => "bar",
    "=" => [
      {"@foo" => "nope", "=" => "Bob"},
      "Sheila"
    ]
  }
)
#=> "<person foo=\"nope\">Bob</person><person foo=\"bar\">Sheila</person>"
```

*This is getting interesting, isn't it?* In this example, we are setting a default "foo" attribute on each of the
items in the collection of &lt;person&gt; nodes. However, you'll notice that we overwrote the default "foo" with Bob.


#### Array of Arrays

Array values are flattened prior to translation, to reduce the need to iterate over nested arrays.

```ruby
XmlFu.xml(
  :foo => [
    [{"a/" => nil}, {"b/" => nil}],
    {"c/" => nil},
    [
      [{"d/" => nil}, {"e/" => nil}],
      {"f/" => nil}
    ]
  ]
)
#=> "<foo><a/><b/><c/><d/><e/><f/></foo>"
```

:foo in this case, is the parent node of it's contents


#### Array of Mixed Types

Since with simple values, you cannot infer the value of their node container purely on their value, simple values
are currently ignored in arrays and only Hashes are translated.

```ruby
  "foo" => [
    {:bar => "biz"},
    nil, # ignored
    true, # ignored
    false, # ignored
    42, # ignored
    3.14, # ignored
    "simple string", # ignored
    ['another','array','of','values'] # ignored
  ]
  #=> "<foo><bar>biz</bar></foo>"
```

## Options
* **:instruct** => true
  * Adds &lt;xml version="1.0" encoding="UTF-8"?&gt; to generated XML


## Cheat Sheet

### Key
  1. if key denotes self-closing node (key/)
    * attributes are preserved with Hash values
    * value and "=" values are ignored
  2. if key denotes collection (key*) with Array value
    * Array is flattened
    * Only Hash and Simple values are translated
    * Hashes may override default attributes set by parent
    * **(applies to Array values only)**
  3. if key denotes contents (key) with Array value
    * Array is flattened
    * Only Hash items in array are translated

### Value
  1. if value is Hash:
    * "@" keys are attributes of the node
    * "=" key can be used in conjunction with any "@" keys to specify content of node
  3. if value is simple value:
    * it is content of <key> node
    * **unless:** key denotes a self-closing node


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
