require 'builder'
require 'xml-fu/hash'
require 'xml-fu/node'

module XmlFu

  # Convert Array to XML String
  class Array

    # Custom exception class
    class MissingKeyException < Exception; end

    # Convert Array to XML String of sibling XML nodes
    # @param [Array] array
    # @param [Hash] options
    # @option options [String] :content_type  Either "collection" or "content". (defaults to "content")
    # @option options [String, Symbol] :key Name of node.
    # @option options [Hash] :attributes Possible hash of attributes to assign to nodes in array.
    # @return String
    def self.to_xml(array, options={})
      each_with_xml(array, options) do |xml, key, item, attributes|
        case options[:content_type].to_s
        when "collection"
          raise(MissingKeyException, "Key name missing for collection") if key.empty?
          
          case 
          when key[-1,1] == "/"
            xml << Node.new(key, nil, attributes).to_xml
          when ::Hash === item
            xml.tag!(key, attributes) { xml << Hash.to_xml(item,options) }
          when ::Array === item
            xml << Array.to_xml(item.flatten,options)
          else
            xml << Node.new(key, item, attributes).to_xml
          end
        else
          # Array is content of node rather than collection of node elements
          case
          when ::Hash === item   
            xml << Hash.to_xml(item, options)
          when ::Array === item  
            xml << Array.to_xml(item, options)
          when XmlFu.infer_simple_value_nodes == true
            xml << infer_node(item, attributes)
          else
            # only act on item if it responds to to_xml
            xml << item.to_xml if item.respond_to?(:to_xml)
          end
        end
      end
    end#self.to_xml

    # Future Functionality - VERY ALPHA STAGE!!!
    # @todo Add node inferrance functionality
    # @note Do not use if you want stable functionality
    # @param item Simple Value
    # @param [Hash] attributes Hash of attributes to assign to inferred node.
    def self.infer_node(item, attributes={})
      node_name = case item.class
                  when "TrueClass"
                  when "FalseClass"
                    "Boolean"
                  else
                    item.class
                  end
      Node.new(node_name, item, attributes).to_xml
    end#self.infer_node

    # Convenience function to iterate over array items as well as
    # providing a single location for logic
    # @param [Array] arr Array to iterate over
    # @param [Hash] opts Hash of options to pass to the iteration
    def self.each_with_xml(arr, opts={})
      xml = Builder::XmlMarkup.new

      arr.each do |item|
        key = opts.fetch(:key, "")
        item_content = item

        # Attributes reuires duplicate or child elements will 
        # contain attributes of their siblings.
        attributes = (opts[:attributes] ? opts[:attributes].dup : {})

        if item.respond_to?(:keys)
          filtered = Hash.filter(item)
          attributes = filtered.last
          item_content = filtered.first
        end

        yield xml, key, item_content, attributes
      end

      xml.target!
    end#self.each_with_xml

  end#Array

end#XmlFu
