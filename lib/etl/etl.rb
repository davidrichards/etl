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
    extract
    advance_from(:extract)
    etl_callback(:after_extract)
    
    etl_callback(:before_transform)
    transform
    advance_from(:transform)
    etl_callback(:after_transform)
    
    etl_callback(:before_load)
    load
    advance_from(:load)
    etl_callback(:after_load)
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
    end
    
    def process_raw_data
      @data = @raw if defined?(@raw)
      @raw = nil
    end

end
