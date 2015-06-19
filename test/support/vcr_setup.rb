require 'rubygems'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/cassettes"
  config.hook_into :webmock # or :fakeweb
  config.ignore_hosts 'codeclimate.com'
end
