$:.unshift File.dirname __FILE__

require 'gmetric'
require 'active_support/core_ext'
require 'eventmachine'
require 'json'

# Long running ganglia client/forwarder for windows and OSX.
module Fakelia
  # Gem Version
  VERSION = '1.0.2'
  
  # Empty module to fill with script modules
  module Scripts
  end
end

require 'fakelia/util'
require 'fakelia/client'
require 'fakelia/application'
