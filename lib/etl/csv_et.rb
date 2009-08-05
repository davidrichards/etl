require 'open-uri'
require 'fastercsv'

module CSV

  # Extract and transform for CSV files: in context (as a string), from a
  # local file, or from a remote file.  Uses FasterCSV and open-uri
  class ET < ETL

    attr_reader :header
    
    after_transform :get_header_conditionally
    
    protected
    
      def get_header_conditionally
        @header = @raw.shift if self.options[:extract_header]
      end
      
      # Attempts to get a string from a file, a uri, or a string
      def extract
        source = self.options.fetch(:source, nil)
        @raw = OpenContent::Extractor.process(source, ET.logger)
      end

      def transform
        opts = self.options.fetch(:parse_with, {})
        ET.logger.info "Parsing the data with FasterCSV and #{default_csv_opts.merge(opts).inspect}"
        @raw = FCSV.parse(@data, default_csv_opts.merge(opts))
      end

      def default_csv_opts; {:converters => :all}; end
  end

  # Try this out for size:
  # file = CSV::ET.process(:source => 'http://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv')
  
end
