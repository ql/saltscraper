require 'bundler/setup'
require 'webmock/rspec'
require 'vcr'
require_relative '../app.rb'

RSpec.configure do |config|
  config.order = :random
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.configure_rspec_metadata!
  config.hook_into :webmock
end
