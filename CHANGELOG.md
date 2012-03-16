### 0.1.2

* Additional nesting support
* Further encapsulated functionality into Node
  * xml.tag! is only used in Node
  * Array collection vs content logic moved to Node
  * Hash iteration logic reduced to a single Node call
* Node
  * New attribute: "content_type"
  * Special tag characters (\*, /, !) can be mixed and matched
    * "foo/\*" will return a collection of <foo/> siblings
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
