require 'open-uri'
module OpenContent
  class Extractor
    class << self
      
      attr_reader :logger
      
      def process(source, logger)
        @logger = logger
        extract_locally(source) or extract_remotely(source) or extract_from_string(source)
        raise ArgumentError, "Could not determine what #{source.inspect} was.  Cannot extract this data." unless @raw
        @raw
      end
      
      protected
        # Handles local filename cases, reading the contents of the file.
        def extract_locally(filename)
          @raw = File.read(filename) if File.exist?(filename)
          self.logger.info "Extracted the data from from filesystem" if @raw
          @raw ? true : false
        end
      
        # Handles remote uri cases, reading the remote resource with open-uri, part of the Standard Library
        def extract_remotely(uri)
          begin
            open(uri) {|f| @raw = f.read}
            self.logger.info "Extracted the data from a remote location."
            return true
          rescue
            self.logger.info "Tested whether #{uri} was a remote resource.  Failed to read it."
            return false
          end
        end
      
        # If this is a string, assumes that the contents of the string are CSV contents.
        def extract_from_string(string)
          @raw = string if string.is_a?(String)
          @raw ? true : false
        end
      
    end
  end
end
