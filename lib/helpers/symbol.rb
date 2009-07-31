class Symbol # :nodoc:
  # From Carl Youngblood's excellent SBN gem: http://sbn.rubyforge.org/
  def to_underscore_sym
    self.to_s.titleize.gsub(/\s+/, '').underscore.to_sym
  end
end
