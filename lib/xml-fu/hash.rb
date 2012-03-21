require 'builder'
require 'xml-fu/array'
require 'xml-fu/node'

module XmlFu

  # By definition, a hash is an UNORDERED list of key/value pairs
  # There's no sense in trying to order the keys.
  # If order is of concern, use Array.to_xml
  class Hash

    # Convert Hash to XML String
    def self.to_xml(hash, options={})
      each_with_xml hash, options do |xml, name, value, attributes|
        xml << Node.new(name, value, attributes).to_xml 
      end
    end#self.to_xml


    # Class method to filter out attributes and content
    # from a given hash
    def self.filter(hash)
      attribs = {}
      content = hash.dup

      content.keys.select{|k| k =~ /^@/ }.each do |k|
        attribs[k[1..-1]] = content.delete(k)
      end

      # Use _content value if defined
      content = content.delete("=") || content

      return [content, attribs]
    end#self.filter

  private

    # Provides a convenience function to iterate over the hash
    # Logic will filter out attribute and content keys from hash values
    def self.each_with_xml(hash, opts={})
      xml = XmlFu::Markup.new(opts)

      hash.each do |key,value|
        node_value = value
        node_attrs = {}

        # yank the attribute keys into their own hash
        if value.respond_to?(:keys)
          filtered = Hash.filter(value)
          node_value, node_attrs = filtered.first, filtered.last
        end

        # Use symbol conversion algorithm to set tag name
        node_name = ( Symbol === key ?
                     XmlFu::Node.symbol_conversion_algorithm.call(key) :
                     key.to_s )

        yield xml, node_name, node_value, node_attrs
      end

      xml.target!
    end#self.each_with_xml

  end#Hash

end#XmlFu
