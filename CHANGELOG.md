## Changes by Version

### 0.1.8

* Fixed XmlFu.symbol_conversion_algorithm functionality
* Added specs for above
* Removed :snake_case algorithm
** It never worked and can be implemented via a custom algorithm.
* Added :upcase algorithm
* Added :downcase algorithm
* Updated README

### 0.1.7

* Added pass through for Builder::XmlMarkup options via XmlFu.xml
  * :indent
  * :margin
* Refactored Builder::XmlMarkup creation logic into separate class

### 0.1.6

* Added :instruct option for adding XML doctype instruction to generated XML

### 0.1.5

* Fix false positive for Node value responding to "to_datetime" by checking explicitly for String values before hand.

### 0.1.4

* Bug Fix with converting non-Array, non-Hash values to their proper XML string equivalent.

### 0.1.2

* Additional nesting support
* Further encapsulated functionality into Node
  * xml.tag! is only used in Node
  * Array collection vs content logic moved to Node
  * Hash iteration logic reduced to a single Node call
* Node
  * New attribute: "content_type"
  * Special tag characters (\*, /, !) can be mixed and matched
    * "foo/\*" will return a collection of &lt;foo/&gt; siblings
* 12 new spec tests
* Removed development dependencies for:
  * autotest
  * mocha

### 0.1.1

* Rescue false positives when setting Node.value due to interaction with ActiveSupport

### 0.1.0

* Initial version. born as a replacement of
  [Gyoku](http://www.rubygems.org/gems/gyoku)
  with corrected assumptions about Array values and
  no need for meta tags such as:
  * :order!
  * :attributes!
