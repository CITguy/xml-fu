module XmlFu
  class Configuration
    # @attr [lambda] symbol_conversion_algorithm (:lower_camelcase)
    #   symbol-to-string conversion algorithm
    attr_reader :symbol_conversion_algorithm # define my own writer

    # @attr [Boolean] fail_on_invalid_construct (false)
    #   By default, XmlFu works for converting Hash, Array, and OpenStruct objects. Any other
    #   type of object will be ignored and the result would return an empty string. With this option
    #   enabled, XmlFu will raise an exception if an unsupported object is attempted to be
    #   converted.
    attr_accessor :fail_on_invalid_construct

    # @attr [Boolean, nil] include_xml_declaration (nil)
    #   If set, will override XmlFu.xml :istruct option for toggling the XML declaration for
    #   the generated output.
    attr_accessor :include_xml_declaration


    ALGORITHMS = {
      :camelcase => lambda { |sym| sym.to_s.camelcase },
      :downcase => lambda { |sym| sym.to_s.downcase },
      :lower_camelcase => lambda { |sym| sym.to_s.lower_camelcase }, # DEFAULT
      :none => lambda { |sym| sym.to_s },
      :upcase => lambda { |sym| sym.to_s.upcase }
    }


    # Set default values
    def initialize
      @symbol_conversion_algorithm = ALGORITHMS[:lower_camelcase]
      @fail_on_invalid_construct = false
      @include_xml_declaration = nil
    end#initialize


    # Method for setting global Symbol-to-string conversion algorithm
    # @param [symbol, lambda] algorithm
    #   Can be symbol corresponding to predefined algorithm or a lambda that accepts a symbol
    #   as an argument and returns a string
    def symbol_conversion_algorithm=(algorithm)
      raise(ArgumentError, "Missing symbol conversion algorithm") unless algorithm

      if algorithm.respond_to?(:call)
        @symbol_conversion_algorithm = algorithm
      else
        if algorithm == :default
          @symbol_conversion_algorithm = ALGORITHMS[:lower_camelcase]
        elsif ALGORITHMS.keys.include?(algorithm)
          @symbol_conversion_algorithm = ALGORITHMS[algorithm]
        else
          raise(ArgumentError, "Invalid symbol conversion algorithm")
        end
      end
    end#symbol_conversion_algorithm

  end#class
end#module
