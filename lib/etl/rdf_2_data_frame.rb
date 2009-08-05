# Requires data_frame (sudo gem install davidrichards-data_frame)
gem 'data_frame'
require 'data_frame'

# This is a simple tool that converts RDF to DataFrames.  It uses the
# subjects as the rows, the objects as the columns, and the predicates
# as the values.  This can make the data much more accessible by more
# analysis tools. 
class RDF2DataFrame < ETL
  
  def extract
    source = self.options.fetch(:source, nil)
    @raw = OpenContent::Extractor.process(source, RDF2DataFrame.logger)
  end
  
  def transform
    # TODO
  end
end
