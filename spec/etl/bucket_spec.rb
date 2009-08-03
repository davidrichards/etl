require File.join(File.dirname(__FILE__), "/../spec_helper")
require 'etl/bucket'

describe Bucket do
  
  before(:all) do
    class A
      def initialize(*args)
        @value = args
      end
      attr_reader :value
    end

    S = Struct.new(:this)
  end
  
  before do
    @b = Bucket.new
    @h = {:this => 1}
    @o = OpenStruct.new(:this => 1)
    @s = S.new(1)
    @b1 = Bucket.new(@h)
  end
  
  it "should create a hash for storing raw, unordered data" do
    @b.raw_data.should be_is_a(Hash)
  end
  
  it "should be able to add a record with a hash" do
    @b.add(@h)
    @b.filtered_data.should == @h
  end
  
  it "should be able to add a record with an OpenStruct" do
    @b.add(@o)
    @b.filtered_data.should == @h
  end
  
  it "should be able to add a record with a Struct" do
    @b.add(@s)
    @b.filtered_data.should == @h
  end
  
  it "should be able to override values" do
    @b.add(@h)
    @b.add(:this => 2)
    @b.filtered_data.should == {:this => 2}
  end
  
  it "should create a way to setup labels" do
    a = [:three, :two, :one]
    @b.labels = a
    @b.labels.all? {|l| a.should be_include(l)}
  end
  
  it "should be constructable with a hash" do
    b = Bucket.new(@h)
    b.filtered_data.should == @h
  end
  
  it "should be constructable with an OpenStruct" do
    b = Bucket.new(@o)
    b.filtered_data.should == @h
  end
  
  it "should be constructable with a Struct" do
    b = Bucket.new(@s)
    b.filtered_data.should == @h
  end
  
  it "should be able to dump the contents of the bucket" do
    @b1.dump.should == @h
    @b1.raw_data.should == {}
  end
  
  it "should be able to take an arbitrary filter" do
    b = Bucket.new(@h) {|h| :not_the_data}
    b.raw_data.should == @h
    b.filtered_data.should eql(:not_the_data)
  end

  it "should be able to return an array" do
    @b1.to_a.should eql([1])
  end
  
  it "should be able to return a hash" do
    @b1.to_hash.should == @h
  end
  
  it "should be able to return any object that initializes with the bucket values" do
    a = @b1.to_obj(A)
    a.value.should eql(@b1.to_a)
  end
  
  it "should be able to return a Struct" do
    s = @b1.to_struct(S)
    s.this.should eql(1)
  end
  
  it "should be able to return an OpenStruct" do
    o = @b1.to_open_struct
    o.table.should == @h
  end
  
  it "should be able to constrain and order keys, silently ignoring data that isn't white listed" do
    h = {:ones => 1, :twos => 2, :threes => 3}
    @b.white_list = [:ones, :twos, :threes]
    @b.add :ones => 1, :twos => 2, :threes => 3, :fours => 4
    @b.filtered_data.should == h
    @b.to_a.should eql([1,2,3])
  end
end
