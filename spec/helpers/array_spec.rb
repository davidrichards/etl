require File.join(File.dirname(__FILE__), "/../spec_helper")

describe Array do
  it "should be able to symbolize values" do
    %w(this Is a teSt).symbolize_values.should eql([:this, :is, :a, :te_st])
  end
  
  it "should be able to symbolize values in place" do
    a = %w(this Is a teSt)
    a.symbolize_values!
    a.should eql([:this, :is, :a, :te_st])
  end
end