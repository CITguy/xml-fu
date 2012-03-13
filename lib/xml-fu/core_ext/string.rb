# Redefined parts of the String class to suit our needs in the gem.
class String

  # Returns the string in camelcase (with first character lowercase)
  def lower_camelcase
    self[0].chr.downcase + self.camelcase[1..-1]
  end#lower_camelcase

  # Returns the string in camelcase (with the first character uppercase)
  def camelcase
    self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end#camelcase

end#String
