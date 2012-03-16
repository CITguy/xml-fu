require 'builder'
require 'cgi'
require 'date'

require 'xml-fu/core_ext/string'

module XmlFu

  # Class to contain logic for converting a key/value pair into an XML node
  class Node

    # Custom exception class
    class InvalidAttributesException < Exception; end

    # xs:dateTime format.
    XS_DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

    # default set of algorithms to choose from
    ALGORITHMS = {
      :lower_camelcase => lambda { |sym| sym.to_s.lower_camelcase },
      :camelcase => lambda { |sym| sym.to_s.camelcase },
      :snakecase => lambda { |sym| sym.to_s },
      :none => lambda { |sym| sym.to_s }
    }

    # Class method for retrieving global Symbol-to-string conversion algorithm
    # @return [lambda]
    def self.symbol_conversion_algorithm
      @symbol_conversion_algorithm ||= ALGORITHMS[:lower_camelcase]
    end#self.symbol_conversion_algorithm

    # Class method for setting global Symbol-to-string conversion algorithm
    # @param [lambda] algorithm Should accept a symbol as an argument and return a string
    def self.symbol_conversion_algorithm=(algorithm)
      algorithm = ALGORITHMS[algorithm] unless algorithm.respond_to?(:call)
      raise(ArgumentError, "Invalid symbol conversion algorithm") unless algorithm
      @symbol_conversion_algorithm = algorithm
    end#self.symbol_conversion_algorithm=

    attr_accessor :escape_xml
    attr_accessor :self_closing
    attr_accessor :content_type

    # Create XmlFu::Node object
    # @param [String, Symbol] name Name of node
    # @param value Simple Value or nil
    # @param [Hash] attributes Optional hash of attributes to apply to XML Node
    def initialize(name, value, attributes={})
      @escape_xml = true
      @self_closing = false
      @content_type = "container"
      self.attributes = attributes
      self.value = value
      self.name = name
    end#initialize

    attr_reader :attributes
    def attributes=(val)
      if ::Hash === val
        @attributes = val
      else
        raise(InvalidAttributesException, "Attempted to set attributes to non-hash value")
      end
    end

    attr_reader :name
    def name=(val)
      use_name = val.dup

      use_name = name_parse_special_characters(use_name)

      # TODO: Add additional logic that Gyoku XmlKey puts in place 
     
      # remove ":" if name begins with ":" (i.e. no namespace)
      use_name = use_name[1..-1] if use_name[0,1] == ":"

      if Symbol === val
        use_name = self.class.symbol_conversion_algorithm.call(use_name)
      end

      # Set name to remaining value
      @name = "#{use_name}"
    end#name=

    # Converts name into proper XML node name
    # @param [String, Symbol] val Raw name
    def name_parse_special_characters(val)
      use_this = val.dup

      # Ensure that we don't have special characters at end of name
      while ["!","/","*"].include?(use_this.to_s[-1,1]) do
        # Will this node contain escaped XML?
        if use_this.to_s[-1,1] == '!'
          @escape_xml = false
          use_this.chop!
        end

        # Will this be a self closing node?
        if use_this.to_s[-1,1] == '/'
          @self_closing = true 
          use_this.chop!
        end

        # Will this node contain a collection of sibling nodes?
        if use_this.to_s[-1,1] == '*'
          @content_type = "collection"
          use_this.chop!
        end
      end

      return use_this
    end#name_parse_special_characters

    # Custom Setter for @value instance method
    def value=(val)
      case val
      when ::Hash     then @value = val
      when ::Array    then @value = val
      when ::DateTime then @value = val.strftime XS_DATETIME_FORMAT
      when ::Time     then @value = val.strftime XS_DATETIME_FORMAT
      when ::Date     then @value = val.strftime XS_DATETIME_FORMAT
      else
        if val.respond_to?(:to_datetime)
          @value = val.to_datetime
        elsif val.respond_to?(:call)
          @value = val.call
        elsif val.nil?
          @value = nil
        else
          @value = val.to_s
        end
      end
    rescue => e
      @value = val.to_s
    end#value=

    # @return [String, nil]
    # Value can be nil, else it should return a String value.
    def value
      return CGI.escapeHTML(@value) if String === @value && @escape_xml
      return @value
    end#value

    # Create XML String from XmlFu::Node object
    def to_xml
      xml = Builder::XmlMarkup.new
      case
      when @self_closing && @content_type == 'container'
        xml.tag!(@name, @attributes)
      when @value.nil? 
        xml.tag!(@name, @attributes.merge!("xsi:nil" => "true"))
      when ::Hash === @value
        xml.tag!(@name, @attributes) { xml << XmlFu::Hash.to_xml(@value) }
      when ::Array === @value
        case @content_type
        when "collection"
          xml << XmlFu::Array.to_xml(@value.flatten, { 
            :key => (@self_closing ? "#{@name}/" : @name),
            :attributes => @attributes,
            :content_type => "collection"
          })
        when "container"
          xml.tag!(@name, @attributes) { xml << XmlFu::Array.to_xml(@value) }
        else
          # Shouldn't be anything else
        end
      else
        xml.tag!(@name, @attributes) { xml << self.value.to_s }
      end
      xml.target!
    end#to_xml

  end#Node

end#XmlFu
