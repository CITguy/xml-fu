module XmlFu
  require 'builder'

  # Pseudo class for holding logic for creating the XmlMarkup object.
  class Markup
    
    # @return [Builder::XmlMarkup]
    def self.new(options={})
      indent = (options.delete(:indent) || 0).to_i
      margin = (options.delete(:margin) || 0).to_i
      instruct = options.delete(:instruct) || false

      xml = Builder::XmlMarkup.new(:indent => indent, :margin => margin)
      xml.instruct! if instruct == true

      return xml
    end#self.new

  end#Markup

end#XmlFu
