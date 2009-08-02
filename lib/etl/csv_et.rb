require 'open-uri'
require 'fastercsv'

module CSV

  # Extract and transform for CSV files: in context (as a string), from a
  # local file, or from a remote file.  Uses FasterCSV and open-uri
  class ET < ETL

    protected
    
      # Attempts to get a string from a file, a uri, or a string
      def extract
        obj = self.options.fetch(:source, nil)
        extract_locally(obj) or extract_remotely(obj) or extract_from_string(obj)
        raise ArgumentError, "Could not determine what #{obj.inspect} was.  CSV::ET cannot work with this data." unless @raw
      end
      
      # Handles local filename cases, reading the contents of the file.
      def extract_locally(filename)
        @raw = File.read(filename) if File.exist?(filename)
        ET.logger.info "Extracted the data from from filesystem" if @raw
        true
      end
      
      # Handles remote uri cases, reading the remote resource with open-uri, part of the Standard Library
      def extract_remotely(uri)
        begin
          open(uri) {|f| @raw = f.read}
          ET.logger.info "Extracted the data from a remote location."
          return true
        rescue
          ET.logger.info "Tested whether #{uri} was a remote resource.  Failed to read it."
          return false
        end
      end
      
      # If this is a string, assumes that the contents of the string are CSV contents.
      def extract_from_string(string)
        @raw = string if string.is_a?(String)
      end

      def transform
        opts = self.options.fetch(:csv_parse_hash, {})
        ET.logger.info "Parsing the data with FasterCSV and #{default_csv_opts.merge(opts).inspect}"
        @raw = FCSV.parse(@data, default_csv_opts.merge(opts))
      end

      def default_csv_opts; {:converters => :all}; end
  end

  # Try this out for size:
  # file = CSV::ET.process(:source => 'http://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv')
  
end
