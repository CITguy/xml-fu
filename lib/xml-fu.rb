#require "xml-fu/version"
require "xml-fu/hash"
require "xml-fu/open_struct"
require "xml-fu/array"
require "xml-fu/markup"
require "xml-fu/configuration"

module XmlFu

  # Convert construct into XML
  def self.xml(construct, options={})

    # Override options for xml_declaration if config is present
    unless self.config.include_xml_declaration.nil?
      options[:instruct] = self.config.include_xml_declaration
    end

    case construct
    when ::OpenStruct then
      OpenStruct.to_xml( construct.dup, options )
    when ::Hash then
      Hash.to_xml( construct.dup, options )
    when ::Array then
      Array.to_xml( construct.dup, options )
    else
      if construct.respond_to?(:to_xml)
        construct.to_xml
      else
        # Options have been exhausted
        if self.config.fail_on_invalid_construct
          raise ArgumentError, "Invalid construct"
        else
          nil
        end
      end
    end
  end#self.xml


  # Used to determine if the top-level #xml method recognizes the passed object
  def self.recognized_object?(obj)
    case obj
    when ::Hash       then return true
    when ::Array      then return true
    when ::OpenStruct then return true
    else
      return true if obj.respond_to?(:to_xml)
      return false
    end
  end#self.recognized_object?


  ################################################################################
  ## CONFIGURATIONS
  ################################################################################

  # Modify configuration for library
  # @yield [Configuration]
  def self.configure
    yield self.config if block_given?
  end#configure


  def self.config
    @@config ||= Configuration.new
  end#self.config


end#XmlFu
