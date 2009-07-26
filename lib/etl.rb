# TODO:
# Test this (a bit of a bugger, because I need to fail at every callback and make sure that I can recover.)
# Get the logging done and demonstrated, because an ETL process without good logging really is useless.
# Include a logging example for syslog-ng and syslog
# Work through some bucket thoughts that I was having this morning: how to take random percepts and create consolidated snapshots of an environment at a point in time.  This is driven from the belief maintenance systems, but certainly needs to be worked out.
# Figure out if TeguGears really should be doing this.  Come back to how I'll parallelize this process.  Demonstrate running this in parallel.

require 'rubygems'
require 'activesupport'

begin
  gem 'tegu_gears'
  require 'tegu_gears'
rescue Gem::LoadError
  # Do nothing if this is not available.  It's a convenience, not a requirement.
end

require 'ostruct'
require 'log4r'

$:.unshift(File.dirname(__FILE__))

require 'etl/etl'
