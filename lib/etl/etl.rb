# State machine with useful callbacks for getting data (Extract,
# Transform, and Loading data) with some support for re-trying failed
# stages of the process.  Raise errors liberally if things go wrong, the
# data is being staged and the process can usually be restarted once the
# issue has been addressed. 

class ETL
  
  VALID_STATES = [:before_extract, :extract, :after_extract, :before_transform, :transform, :after_transform, :before_load, :load, :after_load, :complete].freeze

  # Because we want to interchange these steps on the queueing system
  if defined?(TeguGears) == 'constant'
    include TeguGears
  end
  
  # Using ActiveSupports callback system
  include ActiveSupport::Callbacks
  
  class << self
    
    def process(options={}, &block)
      etl = new
      etl.process(options, &block)
      etl
    end
    alias :call :process

    # Sets up a logger for the class.  Respects inheritance, so a different
    # logger will be created for each ETL subclass. 
    # Using the standard log levels here: DEBUG < INFO < WARN < ERROR < FATAL
    def logger
      
      logger_name = (self.to_s + "_logger").to_sym
      
      # Find and return the cached logger, if it's setup
      logger = read_inheritable_attribute(logger_name)
      return logger if logger
      
      # Create a logger.  Will configure it here and save it in a moment.
      logger = Log4r::Logger.new(self.to_s)
      
      # Set my default output format
      format = Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m")
      
      # Setup a console logger with our formatting
      console = Log4r::StderrOutputter.new 'console'
      console.level = Log4r::WARN
      console.formatter = format
      
      # Setup a logger to a file with our formatting
      logfile = Log4r::FileOutputter.new('logfile', 
                               :filename => File.join(self.logger_root, "#{self.to_s}.log"), 
                               :trunc => false,
                               :level => Log4r::DEBUG)
      logfile.formatter = format
      
      # Tell the logger about both outputs.
      logger.add('console','logfile')
      
      # Store the logger as an inheritable class attribute
      write_inheritable_attribute(logger_name, logger)
      
      # Return the logger
      logger
    end
    
    # First tries to get the cached @@logger_root
    # Second, sets the global @@logger_root unless it is cached.  Sets it to
    # the best possible place to locate the logs: 
    # 1) where log will be from RAILS_ROOT/vendor/gems/etl
    # 2) where log will be in a Rails model
    # 3) where log will be in a Rails lib
    # 4) in the local directory where ETL is being subclassed
    # Third, uses the subclasses stored logger_root, ignoring all the rest
    # if this is found. 
    def logger_root
      @@logger_root ||= case
      when File.exist?(File.dirname(__FILE__) + "/../../../../../log")
        File.expand_path(File.dirname(__FILE__) + "/../../../../../log")
      when File.exist?(File.dirname(__FILE__) + "/../../log")
        File.expand_path(File.dirname(__FILE__) + '/../../log')
      when File.exist?(File.dirname(__FILE__) + "/../log")
        File.expand_path(File.dirname(__FILE__) + '/../log')
      when File.exist?(File.dirname(__FILE__) + "/log")
        File.expand_path(File.dirname(__FILE__) + '/log')
      else
        File.expand_path(File.dirname(__FILE__))
      end
      logger_root = read_inheritable_attribute(:logger_root) || @@logger_root
    end
    
    # Sets the logger root for the subclass, and sets it globally if this is
    # set on ETL.  So, ETL.logger_root = "some location" sets the logger
    # root for all subclasses.  This is useful if a lot of ETL is being done,
    # and it needs to be logged in a non-standard place. 
    def logger_root=(value)
      write_inheritable_attribute(:logger_root, value)
      @@logger_root = value if self == ETL
    end
  end

  # A series of callbacks that make the process quite transparent
  define_callbacks :before_extract, :after_extract, :before_transform, :after_transform, :before_load, :after_load
  
  def initialize
    @state = :before_extract
  end
  
  # The state of the transform process
  attr_reader :state

  # The data being worked on, after it has successfully completed an
  # extract, transform, or load process. 
  attr_reader :data

  # The data generated on a process that didn't complete.  
  attr_reader :raw
  
  # The options to process with.  All your code will have access to these
  # options, so things like: 
  # 
  # :filename => '...', :destination => '...', :converters => :all
  # 
  # would all be useful. Your extract, transform, and load methods
  # plus your callbacks can then extract out the information they need
  # to get the job done. 
  attr_reader :options
  
  # An optional block to process with
  attr_reader :block
  
  # Working towards a universal workflow driver here.  The signature is
  # just a hash and a block.  That should work for about anything. 
  def process(options={}, &block)
    # TODO: Add logging

    # Only setup the options the first time, the other times we are re-
    # starting the process. 
    @options = options unless @options
    @block = block

    etl_callback(:before_extract)
    extract if @state == :extract
    advance_from(:extract)
    etl_callback(:after_extract)
    
    etl_callback(:before_transform)
    transform if @state == :transform
    advance_from(:transform)
    etl_callback(:after_transform)
    
    etl_callback(:before_load)
    load if @state == :load
    advance_from(:load)
    etl_callback(:after_load)
    @state
  end
  
  after_extract :process_raw_data
  after_transform :process_raw_data
  
  def reverse_to(state)
    raise ArgumentError, "State must be one of #{VALID_STATES}" unless VALID_STATES.include?(state)
    loc = VALID_STATES.index(state)
    possible_states = VALID_STATES[0..loc]
    raise "Cannot reverse to a state that hasn't been acheived yet." unless possible_states.include?(state)
    @state = state
  end

  protected
  
    def extract
      # Silently do nothing
    end
  
    def transform
      # Silently do nothing
    end
  
    def load
      # Silently do nothing
    end

    # Runs a callback, if there is one defined on the class.  Advances the
    # state to the next state.  Silently ignores the request if the current
    # state isn't the callback being asked for.  In this way, we can just
    # call etl_callback several times, and it will advance from one state to
    # the next. 
    def etl_callback(callback)
      return false unless self.state == callback
      run_callbacks(callback)
      advance_from(callback)
    end
    
    # Advances to the next state, only if we are in a valid state.
    def advance_from(callback)
      
      raise ArgumentError, "State: #{callback} not recognized" unless VALID_STATES.include?(callback)
      before_state = @state
      @state = case @state
      when :before_extract
        :extract
      when :extract
        :after_extract
      when :after_extract
        :before_transform
      when :before_transform
        :transform
      when :transform
        :after_transform
      when :after_transform
        :before_load
      when :before_load
        :load
      when :load
        :after_load
      when :after_load
        :complete
      when :complete
        :complete
      end
      
      self.class.logger.info "Advanced from #{before_state} to #{@state}"
      
    end
    
    def process_raw_data
      @data = @raw if defined?(@raw)
      @raw = nil
    end

end
