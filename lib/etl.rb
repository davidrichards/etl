# TODO:
# Include a logging example for syslog-ng and syslog
# Work through some bucket thoughts that I was having this morning: how to take random percepts and create consolidated snapshots of an environment at a point in time.  This is driven from the belief maintenance systems, but certainly needs to be worked out.
# Figure out if TeguGears really should be doing this.  Come back to how I'll parallelize this process.  Demonstrate running this in parallel.

require 'rubygems'
gem 'activesupport', '>= 2.3'
require 'activesupport'
require 'ostruct'
require 'log4r'
require 'fileutils'

def load_gem_casually(name)
  begin
    gem name
    require name
  rescue Gem::LoadError
    # Do nothing if this is not available.  It's a convenience, not a requirement.
  end
end

load_gem_casually('tegu_gears')
load_gem_casually('data_frame')
load_gem_casually('babel_icious')

Dir.glob("#{File.dirname(__FILE__)}/helpers/*.rb").each { |file| require file }

$:.unshift(File.dirname(__FILE__))

class ExtractError < StandardError; end
class TransformError < StandardError; end
# Note, LoadError is already used.
class LoadingError < StandardError; end

require 'etl/etl'
