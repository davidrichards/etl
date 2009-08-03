require 'facets/dictionary'

# Sometimes I have data coming from several sources.  I want to combine
# the sources and release a consolidated record.  This is meant to work
# like that.  For a weird example: 
# >> my_hash = {:surprise => 'me'}
# => {:surprise=>"me"}
# >> b = Bucket.new(my_hash) {|h| h.inject({}) {|hsh, e| hsh[e.first] = e.last % 3; hsh}}
# => #<Bucket:0x232d230 @raw_data={:surprise=>"me"}, @filter_block=#<Proc:0x0232d26c@(irb):2>>
# >> b.add :this => 1
# => {:surprise=>"me", :this=>1}
# >> b.add OpenStruct.new(:this => 6)
# => {:surprise=>"me", :this=>6}
# >> b.raw_data
# => {:surprise=>"me", :this=>6}
# >> b.filtered_data
# => {:surprise=>"me", :this=>0}
# >> b.dump
# => {:surprise=>"me", :this=>0}
# >> b.raw_data
# => {}
# A more practical use that I have for this is with screen scraping,
# when I'm getting the source of some concept, I may ask the same site
# for information at different times, or ask complimentary sites for
# overlaying data.  A much more practical use of this is with the
# TimeBucket.  That is a bucket that creates a time series from
# observations that may be on very different time schedules. 
class Bucket
  
  # The block used to filter the bucket.  Useful for converting the data
  # to a different data type. 
  # Examples:
  # Return a hash
  # b.filter_block = lambda{|o| o.table}
  # Return an array
  # b.filter_block = lambda{|o| o.table.values}
  attr_accessor :filter_block
  
  # The data in the bucket, as an OpenStruct
  attr_reader :raw_data
  
  def initialize(obj=nil, &block)
    @filter_block = block
    reset_bucket
    assert_object(obj) if obj
  end
  
  def add(obj)
    assert_object(obj)
  end
  
  def dump
    data = self.raw_data
    reset_bucket
    filter(data)
  end
  
  def filtered_data
    filter(self.raw_data)
  end
  
  # Uses the facets/dictionary to deliver an ordered hash, in the order of
  # the white list. 
  def ordered_data
    return self.raw_data unless self.white_list
    dictionary = Dictionary.new
    self.white_list.each do |k|
      dictionary[k] = self.raw_data[k]
    end
    dictionary
  end
  
  def to_a
    self.ordered_data.values
  end
  alias :to_array :to_a
  
  alias :to_hash :raw_data

  # Initializes a class with the values of the raw data.  Good for structs
  # and struct-like classes. 
  def to_obj(klass, use_hash=false)
    use_hash ? klass.new(self.raw_data) : klass.new(*self.raw_data.values)
  end
  alias :to_struct :to_obj
  
  def to_open_struct
    OpenStruct.new(self.raw_data)
  end
  
  # Reveals the white list.  If this is set, it is an array, and it not
  # only filters the data in the bucket, but also orders it. 
  attr_reader :white_list
  alias :labels :white_list

  # Sets the white list, if it's an array.  Filters the raw data, in case
  # there are illegal values in there. 
  def white_list=(value)
    raise ArgumentError, "Must provide and array" unless value.is_a?(Array)
    @white_list = value
    @raw_data = filter_input(self.raw_data)
  end
  alias :labels= :white_list=
  
  
  protected
    # Filters the input through the filter_block.  Use filtered_data if you
    # just want the data in the bucket. 
    def filter(data)
      self.filter_block ? self.filter_block.call(data) : data
    end
  
    def reset_bucket
      @raw_data = Hash.new
    end

    def assert_object(obj)
      case obj
      when Hash
        obj = filter_input(obj)
        self.raw_data.merge!(obj)
      when OpenStruct
        obj = filter_input(obj.table)
        self.raw_data.merge!(obj)
      when Struct
        obj.each_pair do |k, v|
          if self.white_list
            self.raw_data[k] = v if self.white_list.include?(v)
          else
            self.raw_data[k] = v
          end
        end
      else
        raise ArgumentError, "Don't know how to use this data"
      end
    end
    
    def filter_input(hash)
      if self.white_list
        hash = hash.inject({}) do |h, e|
          h[e.first] = e.last if self.white_list.include?(e.first)
          h
        end
      end
      hash
    end
    
end