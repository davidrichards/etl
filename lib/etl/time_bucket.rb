# This keeps the state of all observations in a bucket.  An observation
# is expected to be an OpenStruct with an occured_at field set.  An
# Observation class is provided in the helpers directory and is
# automatically loaded with this gem.  This is setup to work well in the
# observable pattern.

# Uses 
class TimeCachedOpenStruct
  
  attr_reader :tick_time
  attr_reader :keep_for
  attr_reader :cache
  
  def initialize(opts={})
    @tick_time = opts.fetch(:tick_time, 1)
    @keep_for = opts.fetch(:keep_for, self.tick_time * 100)
    @cache = ... (hash structure)
  end
  
  def at(time)
    self.cache[index_for(time)]
  end
  
  protected
    def index_for(time)
      ...
    end
    
    def round(time)
    end
end

require 'observable'
class TimeBucket
  
  include Observer
  
  class << self
    
    # Works more like a multiton with subclasses.  Each subclass gets their
    # own instance. 
    def instance(opts={})
      instance = read_inheritable_attribute(:instance)
      return instance if instance
      instance = new(opts)
      write_inheritable_attribute(:instance, instance)
      instance
    end
  end
  
  # How often the state is broadcast
  attr_reader :tick_time
  
  # How long to wait for messages to be gathered in the bucket.  If they
  # are not gathered by this time, they will never be broadcast. 
  attr_reader :delay_time
  
  # The actual state data, a OpenStruct-based cache with a time-based
  # eviction_policy and a time-based accessor:
  # TimeBucket.bucket.at(time_object) 
  attr_reader :bucket
  
  def initialize(opts={})
    @tick_time = opts.fetch(:tick_time, 1)
    @delay_time = opts.fetch(:delay_time, 0.5)
    keep_time = self.tick_time * 100 + self.delay_time
    @bucket = TimeCachedOpenStruct.new(:tick_time => self.tick_time, :keep_for => keep_time)
  end
  
  # To be called in its own process:
  # Process.fork { TimeBucket.instance(...).service(@etl) }
  # @etl is an object that responds to process and can load the consolidated data.
  def service(etl)
    sleep self.delay_time
    loop do
      changed
      notify_observers(self.bucket.at(Time.now - self.sleep_time))
      sleep self.tick_time
    end
  end
  
  def update(obj)
    observation = infer_observation(obj)
    self.bucket.merge!(observation)
  end
  
  protected
    def infer_observation(obj)
      if obj.respond_to?(occured_at)
        obj
      elsif obj.respond_to?(observation) and obj.observation.occured_at
        obj.observation
      elsif obj.is_a?(OpenStruct)
        obj.occured_at = Time.now
        obj
      elsif obj.is_a?(Hash)
        observation = Observation.new(obj)
        observation.occured_at = obj.fetch(:occured_at, Time.now)
        observation
      else
        nil
      end
    end
end