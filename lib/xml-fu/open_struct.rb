require 'ostruct'
require 'builder'
require 'xml-fu/node'

module XmlFu
  # An OpenStruct object behaves similar to a Hash in that it has key/value pairs,
  # but is more restrictive with key names. As such, it is near impossible to set "attribute"
  # keys on an OpenStruct object.
  class OpenStruct

    def self.to_xml(obj, options={})
      Hash.to_xml(obj.marshal_dump, options)
    end#self.to_xml

  end#class

end#module
