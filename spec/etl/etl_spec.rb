require File.join(File.dirname(__FILE__), "/../spec_helper")

describe ETL do
  
  after(:all) do
    FileUtils.rm_f(ETL.logger_filename)
  end
  
  it "should have a series of valid states" do
    ETL::VALID_STATES.should eql([
      :before_extract, 
      :extract,
      :after_extract, 
      :before_transform, 
      :transform,
      :after_transform, 
      :before_load, 
      :load,
      :after_load, 
      :complete
    ])
  end
  
  context "Class Methods" do
    it "should be able to process the ETL class" do
      val = ETL.process
      val.should be_is_a(ETL)
      val.state.should eql(:complete)
    end
    
    it "should be able to run call as an alias to process" do
      val = ETL.call
      val.should be_is_a(ETL)
      val.state.should eql(:complete)
    end
    
    it "should have a logger" do
      ETL.logger.should be_is_a(Log4r::Logger)
      ETL.logger.name.should eql('ETL')
    end
    
    it "should have a console logger" do
      cl = ETL.logger.outputters.find {|l| l.is_a?(Log4r::StderrOutputter)}
      cl.name.should eql('console')
      cl.level.should eql(Log4r::WARN)
      cl.formatter.should be_is_a(Log4r::PatternFormatter)
      cl.formatter.pattern.should eql("[%l] %d :: %m")
    end

    it "should have a file logger" do
      fl = ETL.logger.outputters.find {|l| l.is_a?(Log4r::FileOutputter)}
      fl.name.should eql('logfile')
      fl.filename.should match(/ETL.log$/)
      fl.formatter.pattern.should eql("[%l] %d :: %m")
    end
    
    it "should log a script to duplicate the ETL" do
      ETL.process(:funny => :options)
      r = Regexp.new(Regexp.escape("ETL.process(:funny => :options)"))
      logger_contents.should match(r)
    end
    
  end
  
  it "should have a beginning state of :before_extract" do
    ETL.new.state.should eql(:before_extract)
  end
  
  it "should have data and raw readers" do
    e = ETL.new
    e.should be_respond_to(:data)
    e.should be_respond_to(:raw)
  end
  
  context "Process" do
    it "should call each transition" do
      PostBoard.reset
      CheckTransitions.process
      PostBoard.board.should eql([:before_extract, :extract, :after_extract, :before_transform, :transform, :after_transform, :before_load, :load, :after_load])
    end
    
    it "should use raw as a data holding bucket, useful for using post-transactional validations" do
      PostBoard.reset
      ShowRaw.process
      PostBoard.board.should eql([nil, :extract, :extract, nil, :transform, :transform, nil, :load, :load])
    end

    it "should convert raw to data after each step" do
      PostBoard.reset
      ShowData.process
      PostBoard.board.should eql([nil, nil, nil, :extract, :extract, :extract, :transform, :transform, :transform])
    end
    
    it "should be able to reverse back to a prior state and restart" do
      PostBoard.reset
      counter = ShowCounter.new
      counter.process
      PostBoard.board.last.should eql(9)
      counter.reverse_to(:transform)
      counter.process
      PostBoard.board.last.should eql(14)
    end
    
    it "should move data in @raw to @data at every stage" do
      etl = ExplicitRawToDataShow.new
      etl.process
      etl.data.should eql(2)
    end

  end
end

class PostBoard
  class << self
    def post(value)
      self.board << value
    end
    
    def board
      @@board ||= []
    end
    
    def reset
      @@board = []
    end
  end
end

# Setting up for various ETL tests.  Must implement post_state with an optional paramater
class Demo < ETL
  before_extract :post_state
  after_extract :post_state
  before_transform :post_state
  after_transform :post_state
  before_load :post_state
  after_load :post_state
  
  def extract
    post_state(:extract)
  end
  
  def transform
    post_state(:transform)
  end
  
  def load
    post_state(:load)
  end
  
end

# Doesn't do much but mark that the states were passed.
class CheckTransitions < Demo
  def post_state(s=nil)
    s ||= self.state
    PostBoard.post s
  end
end

# Marks the value of raw at every transition
class ShowRaw < Demo
  
  def extract
    @raw = :extract
    post_state(self.raw)
  end
  
  def transform
    @raw = :transform
    post_state(self.raw)
  end
  
  def load
    @raw = :load
    post_state(self.raw)
  end
  
  def post_state(s=nil)
    s ||= self.raw
    PostBoard.post s
  end
end

class ShowData < Demo
  
  def extract
    @raw = :extract
    post_state(self.data)
  end
  
  def transform
    @raw = :transform
    post_state(self.data)
  end
  
  def load
    @raw = :load
    post_state(self.data)
  end
  
  def post_state(s=nil)
    s ||= self.data
    PostBoard.post s
  end
end

class ShowCounter < Demo
  
  def advance_count
    @count = self.count + 1
  end
  
  def count
    @count ||= 0
  end
  
  def extract
    post_state
  end
  alias :transform :extract
  alias :load :extract
    
  def post_state
    advance_count
    PostBoard.post self.count
  end
end

class ExplicitRawToDataShow < ETL
  def extract
    @raw = 1
  end
  
  def transform
    @raw = @data + 1
  end
end