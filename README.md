# XmlFu 
[![Gem Version](https://badge.fury.io/rb/xml-fu.png)](http://badge.fury.io/rb/xml-fu)
[![Build Status](https://travis-ci.org/CITguy/xml-fu.png?branch=master)](https://travis-ci.org/CITguy/xml-fu)
[![Coverage Status](https://coveralls.io/repos/CITguy/xml-fu/badge.png?branch=master)](https://coveralls.io/r/CITguy/xml-fu?branch=master)

*license:* MIT

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

## BREAKING CHANGES in 0.2.0

Configuration was reworked to be more flexible and provide a centralized object for configuration. As such,
the configuration options have been moved off of the `XmlFu` module into the `XmlFu.config` object. The `XmlFu.configure`
method still works the same for setting configurations, but for reading configuration variables, you need to go
through the `XmlFu.config` object.

* ADDED
    * support for OpenStruct conversion
* REMOVED
    * `infer_simple_value_nodes` configuration option
    * `XmlFu::Array.infer_node`
    * `XmlFu.parse()`
        * XmlFu is for generation of XML, not parsing.
* MOVED
    * configuration options moved to `XmlFu.config`


# Documentation

* [Hash Keys](#hash-keys)
    * [Key Translation](#key-translation)
    * [Types of Nodes](#types-of-nodes)
* [Hash Values](#hash-values)
    * [Simple Values](#simple-values)
    * [Hashes](#hashes)
    * [OpenStructs](#openstructs)
    * [Arrays](#arrays)
* [Options](#options)
* [Configuration](#configuration)
* [Cheat Sheet](#cheat-sheet)

## Hash Keys

Hash keys are translated into XML nodes (whether it be a document node or attribute node).


### Key Translation

With Ruby, a hash key may be a string or a symbol.  **Strings will be preserved** as they may
contain node namespacing (`<foo:Bar>` would need preserved rather than converted).  There are some
exceptions to this rule (especially with special key syntax discussed in *Types of Nodes* and the
like).  Symbols will be converted into an XML safe name by lower camel-casing them. So `:foo_bar`
will become `fooBar`.  You may change the conversion algorithm to your liking by setting the
`XmlFu.config.symbol_conversion_algorithm` to a lambda or proc of your liking.


#### Built-In Algorithms

For a complete list, reference `XmlFu::Configuration::ALGORITHMS`

* `:camelcase`
* `:downcase`
* `:lower_camelcase` **(default)**
* `:none` (result of `:sym.to_s`)
* `:upcase`

```ruby
# Default Algorithm (:lower_camelcase)
XmlFu.xml( :FooBar => "bang" )  #=> "<fooBar>bang</fooBar>"
XmlFu.xml( :foo_bar => "bang" ) #=> "<fooBar>bang</fooBar>"


# Built-in Algorithms (:camelcase)
XmlFu.config.symbol_conversion_algorithm = :camelcase
XmlFu.xml( :Foo_Bar => "bang" ) #=> "<FooBar>bang</FooBar>"
XmlFu.xml( :foo_bar => "bang" ) #=> "<FooBar>bang</FooBar>"


# Built-in Algorithms (:downcase)
XmlFu.config.symbol_conversion_algorithm = :downcase
XmlFu.xml( :foo_bar => "bang" ) #=> "<foo_bar>bang</foo_bar>"
XmlFu.xml( :Foo_Bar => "bang" ) #=> "<foo_bar>bang</foo_bar>"
XmlFu.xml( :FOO => "bar" )      #=> "<foo>bar</foo>"


# Built-in Algorithms (:upcase)
XmlFu.config.symbol_conversion_algorithm = :upcase
XmlFu.xml( :foo_bar => "bang" ) #=> "<FOO_BAR>bang</FOO_BAR>"
XmlFu.xml( :Foo_Bar => "bang" ) #=> "<FOO_BAR>bang</FOO_BAR>"
XmlFu.xml( :foo => "bar" )      #=> "<FOO>bar</FOO>"


# Custom Algorithm
XmlFu.config.symbol_conversion_algorithm = lambda {|sym| sym.do_something_special }
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


##### Default Functionality (Escaped Characters)

```ruby
XmlFu.xml("foo" => "<bar/>") #=> <foo>&lt;bar/&gt;</foo>
```

##### Unescaped Characters

```ruby
XmlFu.xml("foo!" => "<bar/>") #=> <foo><bar/></foo>
```


#### Attribute Node (@key)

Yes, the attributes of an XML node are nodes themselves, so we need a way of defining them. Since XPath syntax
uses `@` to denote an attribute, so does XmlFu.

**Note**: Keep in mind, because of the way that `XML::Builder` accepts an attributes hash and the way that
Ruby stores and retrieves values from a Hash, attributes won't always be generated in the same order. 
We can only guarantee that the attributes will be _present_, not in any specific order.

``` ruby
XmlFu.xml(:agent => {
  "@id" => "007",
  "FirstName" => "James",
  "LastName" => "Bond"
})
```

```xml
<agent id="007">
  <FirstName>James</FirstName>
  <LastName>Bond</LastName>
</agent>
```


## Hash Values
The value in a key/value pair describes the key/node. Different value types determine the extent of this description.


### Simple Values
Simple value types describe the contents of the XML node.


#### Strings

``` ruby
XmlFu.xml( :foo => "bar" )  #=> <foo>bar</foo>
XmlFu.xml( "foo" => "bar" ) #=> <foo>bar</foo>
```


#### Numbers

``` ruby
XmlFu.xml( :foo => 0 )      #=> <foo>0</foo>
XmlFu.xml( :pi => 3.14159 ) #=> <pi>3.14159</pi>
```


#### Nil

``` ruby
XmlFu.xml( :foo => nil ) #=> <foo xsi:nil="true"/>
```


### Hashes

Hash are parsed for their translated values prior to returning a XmlFu value.

```ruby
XmlFu.xml(:foo => {
  :bar => {
    :biz => "bang"
  }
})
```

```xml
<foo>
  <bar>
    <biz>bang</biz>
  </bar>
</foo>
```

#### Content in Hash (=)

Should you require setting node attributes as well as setting the value of the XML node, you may use the `=`
key in a nested hash to denote explicit content.

```ruby
XmlFu.xml(:agent => {
  "@id" => "007", 
  "=" => "James Bond"
})
```

```xml
<agent id="007">James Bond</agent>
```

This key will not get around the self-closing node rule. The only nodes that will be used in this case will be
attribute nodes (additional content will be ignored).


```ruby
XmlFu.xml("foo/" => {
  "@id" => "123", 
  "=" => "You can't see me."  # ignored (node is self-closing)
})
```

```xml
<foo id="123"/>
```


### OpenStructs

Since version 0.2.0, support has been added for converting an OpenStruct object. OpenStruct objects behave
similar to Hashes, but they do not allow the flexibility that Hashes provide when naming keys/methods. As such,
the advanced naming capabilities are not available with OpenStruct objects and key conversion will go through
`XmlFu.config.symbol_conversion_algorithm`.


### Arrays

Since the value in a key/value pair is (for the most part) used as the contents of a node, there are some
assumptions that XmlFu makes when dealing with Array values.

* For a typical key, the contents of the array are considered to be nodes to be contained within the `<key>` node.


#### Array of Hashes

```ruby
XmlFu.xml( "SecretAgents" => [
  { "agent/" => { "@id"=>"006", "@name"=>"Alec Trevelyan" } },
  { "agent/" => { "@id"=>"007", "@name"=>"James Bond" } }
])
```

```xml
<SecretAgents>
  <agent name="Alec Trevelyan" id="006"/>
  <agent name="James Bond" id="007"/>
</SecretAgents>
```


#### Alternate Array of Hashes (key\*)

There comes a time that you may want to declare the contents of an array as a collection of items denoted by the
key name. Using the asterisk (also known for multiplication --- hence multiple keys) we denote that we want a
collection of &lt;key&gt; nodes.

```ruby
XmlFu.xml( "person*" => ["Bob", "Sheila"] )
```

```xml
<person>Bob</person>
<person>Sheila</person>
```

In this case, the value of "person*" is an array of two names. These names are to be the contents of multiple
`<person>` nodes and the result is a set of sibling XML nodes with no parent.

How about a more complex example:

```ruby
XmlFu.xml(
  "person*" => {
    "@foo" => "bar",
    "=" => [
      { 
        "@foo" => "nope", # override default
        "=" => "Bob"
      },
      "Sheila"
    ]
  }
)
```

```xml
<person foo="nope">Bob</person>
<person foo="bar">Sheila</person>
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
```

```xml
<foo>
  <a/>
  <b/>
  <c/>
  <d/>
  <e/>
  <f/>
</foo>
```

`:foo` in this case, is the parent node of its contents


#### Array of Mixed Types

Since with simple values, you cannot infer the value of their node container purely on their value, simple values
are currently ignored in arrays and only Hashes are translated.

```ruby
XmlFu.xml("foo" => [
  {:bar => "biz"},
  nil,                              # ignored
  true,                             # ignored
  false,                            # ignored
  42,                               # ignored
  3.14,                             # ignored
  "simple string",                  # ignored
  ['another','array','of','values'] # ignored
])
```

```xml
<foo>
  <bar>biz</bar>
</foo>
```

## Options

The following options are available to pass to `XmlFu.xml(obj, options)`.

* `:instruct`
    * if `true`:
        * Adds `<xml version="1.0" encoding="UTF-8"?>` to generated XML
    * This will be overridden by `XmlFu.config.include_xml_declaration`

## Configuration
```ruby
XmlFu.configure do |config|
  config.symbol_conversion_algorithm = :default  # (:lower_camelcase)
  config.fail_on_invalid_construct = false       # (false)
  config.include_xml_declaration = nil           # (nil)
end
```

### symbol\_conversion\_algorithm

This is used to convert symbol keys in a Hash to Strings.


### fail\_on\_invalid_construct

When an unsupported object is passed to `XmlFu.xml()`, the default action is to return `nil` as
the result. When `fail_on_invalid_construct` is enabled, `XmlFu.xml()` will raise an ArgumentError
to denote that the passed object is not supported rather than fail silently.

### include\_xml\_declaration

Deals with adding/excluding `<?xml version="1.0" encoding="UTF-8"?>` to generated XML

* When `true`, ALWAYS adds declaration to XML
* When `false`, NEVER adds declaration to XML
* When `nil`, control is given to `:instruct` option of `XmlFu.xml()` (default)




## Cheat Sheet

### Key
  1. if key denotes self-closing node (key/)
      * attributes are preserved with Hash values
      * value and `=` values are ignored
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
      * `@` keys are node _attributes_
      * `=` key can be used to specify node _content_
  2. if value is simple value:
      * it is the node content
      * **unless:** key denotes a self-closing node


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
