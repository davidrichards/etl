class OpenStruct
    
  def table
    @table
  end
  
  def keys
    self.table.keys
  end
  
  def values
    self.table.values
  end
  
  def include?(key)
    self.keys.include?(key)
  end
end
