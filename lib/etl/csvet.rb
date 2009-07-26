require 'open-uri'
require 'fastercsv'

# Extract and transform for CSV files: in context (as a string), from a
# local file, or from a remote file.  Uses FasterCSV and open-uri
class CSVET < ETL
  
  protected
    def extract
      obj = self.options.fetch(:source, nil)
      @raw = File.read(obj) if File.exist?(obj)
      begin
        open(obj) {|f| @raw = f.read} unless @raw
      rescue
        nil
      end
      @raw ||= obj if obj.is_a?(String)
      return nil unless @raw
    end

    def transform
      opts = self.options.fetch(:csv_parse_hash, {})
      @raw = FCSV.parse(@data, default_csv_opts.merge(opts))
    end

    def default_csv_opts; {:converters => :all}; end
end

# Try this out for size:
# file = CSVET.process(:source => 'http://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv')