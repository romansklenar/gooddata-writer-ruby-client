$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'keboola/gooddata_writer'

require 'minitest/autorun'

# pull in the VCR setup
require File.expand_path './support/vcr_setup.rb', __dir__

