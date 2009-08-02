require File.join(File.dirname(__FILE__), "/../spec_helper")
require 'etl/csv_et'

describe CSV::ET do
  
  before do
    @csv_file = File.expand_path("#{File.dirname(__FILE__)}/../fixtures/test_file.csv")
  end
  
  it "should be able to transform a csv file into an array of arrays" do
    @etl = CSV::ET.process(:source => @csv_file)
    @etl.data.should be_is_a(Array)
    @etl.data.size.should eql(3)
    @etl.data.first.should eql(["some", "data", "here"])
    @etl.data.last.should eql([4,5,6])
  end
  
  it "should be able to transforrm csv data into an array of arrays" do
    content = File.read(@csv_file)
    @etl = CSV::ET.process(:source => content)
    @etl.data.should be_is_a(Array)
    @etl.data.size.should eql(3)
    @etl.data.first.should eql(["some", "data", "here"])
    @etl.data.last.should eql([4,5,6])
  end
  
  it "should be able to pull the header out of the extracted data" do
    @etl = CSV::ET.process(:source => @csv_file, :extract_header => true)
    @etl.header.should eql(["some", "data", "here"])
    @etl.data.first.should eql([1,2,3])
  end
  
  it "should be able to use the FasterCSV options" do
    FasterCSV::Converters[:foo] = lambda{|f| :foo }
    @etl = CSV::ET.process(
      :source => @csv_file, 
      :extract_header => true, 
      :parse_with => {:converters => :foo}
    )
    @etl.header.should eql([:foo, :foo, :foo])
    @etl.data.first.should eql([:foo, :foo, :foo])
  end
end