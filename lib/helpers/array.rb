class Array # :nodoc:
  # From Carl Youngblood's excellent SBN gem: http://sbn.rubyforge.org/
  def symbolize_values
    self.map {|e| e.to_underscore_sym }
  end
  
  # From Carl Youngblood's excellent SBN gem: http://sbn.rubyforge.org/
  def symbolize_values!
    self.map! {|e| e.to_underscore_sym }
  end
end
