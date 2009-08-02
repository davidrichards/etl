require File.join(File.dirname(__FILE__), "/../spec_helper")

describe String do
  it "should be able to create a underscored symbol" do
    sym = 'This AndThat'.to_underscore_sym
    sym.should eql(:this_and_that)
  end
end