class String # :nodoc:
  # From Carl Youngblood's excellent SBN gem: http://sbn.rubyforge.org/
  def to_underscore_sym
    self.titleize.gsub(/\s+/, '').underscore.to_sym
  end
end
