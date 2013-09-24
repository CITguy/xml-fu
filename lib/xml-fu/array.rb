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

          case item
          when ::Array then
            xml << Array.to_xml(item.flatten,options)
          else
            xml << Node.new(key, item, attributes).to_xml
          end
        else
          # Array is content of node rather than collection of node elements
          if XmlFu.recognized_object?(item)
            xml << XmlFu.xml(item, options)
          else
            # unknown xml transformation
          end
        end
      end
    end#self.to_xml


    # Convenience function to iterate over array items as well as
    # providing a single location for logic
    # @param [Array] arr Array to iterate over
    # @param [Hash] opts Hash of options to pass to the iteration
    def self.each_with_xml(arr, opts={})
      xml = XmlFu::Markup.new(opts)

      arr.each do |item|
        key = opts.fetch(:key, "")
        item_content = item

        # Attributes reuires duplicate or child elements will
        # contain attributes of their siblings.
        attributes = (opts[:attributes] ? opts[:attributes].dup : {})

        if item.respond_to?(:keys)
          filtered = Hash.filter(item)
          item_content, attributes = filtered.first, filtered.last
        end

        item_name = ( Symbol === key ?
                     XmlFu.config.symbol_conversion_algorithm.call(key) :
                     key.to_s )

        yield xml, item_name, item_content, attributes
      end

      xml.target!
    end#self.each_with_xml

  end#Array

end#XmlFu
