# This is a base class that uses ETL and Zach Dennis' excellent ar-
# extensions gem.  To get the gem, just: 
# 
# sudo gem install ar-extensions
# 
# See:
# http://www.igvita.com/2007/07/11/efficient-updates-data-import-in-rails/
# http://agilewebdevelopment.com/plugins/ar_extensions
# http://www.continuousthinking.com/

# To use this, 1) setup an extract to find the data, and 2) a transform to
# create an array of arrays, with the first array as the header.  The
# header and data should only contain values in the table to be imported.
# The data_frame gem (sudo gem install davidrichards-data_frame)
# may make the transform a LOT easier to do if there is a lot of column
# munging to do.  Chris Wycoff's babel_icious gem will go a long way in
# the transform if you have XML data you are working with 
# (sudo gem install cwycoff-babel_icious).

gem 'ar-extensions'
require 'ar-extensions'
class ActiveRecordLoader < ETL
  
  after_transform :ensure_array_of_arrays
  before_load :ensure_class_defined
  before_load :assert_header
  
  protected
  
    def ensure_array_of_arrays
      # Not 100% whether I process raw_data before or after this method.  I think before.
      data = @raw || @data
      raise ArgumentError, 
        "Expecting transformed data to be an array of arays" unless
        data.is_a?(Array) and data.first.is_a?(Array) and data.last.is_a?(Array)
    end
    
    def assert_header
      @header ||= @data.shift
      @header.symbolize_values!
    end
    
    def ensure_class_defined
      raise ArgumentError, 
        "Must provide a class to import to.  Try #{self.to_a}.instance.options[:class] = ModelClassName" unless
          self.options[:class]
    end
    
    def load
      options[:class].import(@header, @data)
    end
end
