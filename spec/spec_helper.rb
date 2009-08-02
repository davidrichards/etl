$: << File.join(File.dirname(__FILE__), "/../lib") 
require 'rubygems' 
require 'spec' 
require 'etl'

require 'tempfile'
ETL.logger_root = Dir.tmpdir

Spec::Runner.configure do |config|
  
end

def logger_contents
  File.read(ETL.logger_filename)
end