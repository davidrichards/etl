require File.join(File.dirname(__FILE__), "/../spec_helper")

describe Observation do
  
  before do
    @o = Observation.new
  end
  
  it "should be an OpenStruct" do
    @o.should be_is_a(OpenStruct)
  end
  
  it "should set occurred_at" do
    @o.occured_at.should be_close(Time.now, 0.0001)
  end
  
  it "should make a setter and getter for occured_at" do
    t = Time.now - 100
    @o.occured_at = t
    @o.occured_at.should eql(t)
  end
end