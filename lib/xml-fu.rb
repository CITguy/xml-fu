#require "xml-fu/version"
require "xml-fu/hash"
require "xml-fu/array"
require "xml-fu/markup"

module XmlFu
  class << self
    
    # Convert construct into XML
    def xml(construct, options={})
      case construct
      when ::Hash   then Hash.to_xml( construct.dup, options )
      when ::Array  then Array.to_xml( construct.dup, options )
      else nil
      end
    end#convert

    # @todo Add Nori-like parsing capability to convert XML back into XmlFu-compatible Hash/Array
    # Parse XML into array of hashes.  If XML used as input contains only sibling nodes, output 
    # will be array of hashes corresponding to those sibling nodes.
    #
    #     <foo/><bar/> => [{"foo/" => ""}, {"bar/" => ""}]
    #
    # If XML used as input contains a full document with root node, output will be
    # an array of one hash (the root node hash)
    #
    #     <foo><bar/><baz/></foo> => [{"foo" => [{"bar/" => ""},{"baz/" => ""}] }]
    def parse(xml=nil, options={})
      parsed_xml = xml

      return Array(parsed_xml)
    end

    def configure
      yield self
    end

    ################################################################################
    ## CONFIGURATIONS
    ################################################################################
    
    @@infer_simple_value_nodes = false

    # Set configuration option to be used with future releases
    def infer_simple_value_nodes=(val)
      @@infer_simple_value_nodes = val
    end

    # Configuration option to be used with future releases
    # This option should allow for the inferrance of parent node names of simple value types
    #
    # Example:
    #     1 => <Integer>1</Integer>
    #     true => <Boolean>true</Boolean>
    #
    # This is disabled by default as it is conflicting with working logic.
    def infer_simple_value_nodes
      return @@infer_simple_value_nodes
    end

  end#class<<self
end#XmlFu
