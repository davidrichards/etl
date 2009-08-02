require File.join(File.dirname(__FILE__), "/../spec_helper")

describe OpenStruct do

  before do
    @o = OpenStruct.new(:this => :that)
  end
  
  it "should make the table available." do
    @o.table.should ==({:this => :that})
  end
  
  it "should make the keys to the table available" do
    @o.keys.should eql([:this])
  end
  
  it "should make the values available" do
    @o.values.should eql([:that])
  end
  
  it "should be able to check if a key is included in the keys" do
    @o.should be_include(:this)
    @o.should_not be_include(:that)
  end
end
