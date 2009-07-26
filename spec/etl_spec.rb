require File.dirname(__FILE__) + '/spec_helper'

describe "Etl" do
  it "should use rubygems" do
    defined?(Gem).should eql('constant')
  end
  
  it "should use ActiveSupport" do
    defined?(ActiveSupport).should eql('constant')
  end
  
  it "should use OpenStruct" do
    defined?(OpenStruct).should eql('constant')
  end
  
end
