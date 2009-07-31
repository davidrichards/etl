# Generic OpenStruct, with occured_at automatically set to the initialization time.
class Observation < OpenStruct
  def initialize(*args)
    @occured_at = Time.now
    super
  end
  
  # Need to know when the observation was recorded to batch observations
  attr_accessor :occured_at
end
