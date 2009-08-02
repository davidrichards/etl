require File.join(File.dirname(__FILE__), "/../spec_helper")

describe Symbol do
  it "should be able to convert itself to an underscored symbol" do
    :thisAndThat.to_underscore_sym.should eql(:this_and_that)
  end
end