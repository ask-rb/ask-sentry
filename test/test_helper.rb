# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
    add_filter "/lib/ask/sentry/version.rb"
    track_files "lib/**/*.rb"
    command_name "Unit Tests"
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ask-sentry"
require "minitest/autorun"
require "mocha/minitest"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path("cassettes", __dir__)
  config.hook_into :webmock
  config.filter_sensitive_data("<SENTRY_TOKEN>") { ENV.fetch("SENTRY_TOKEN", "sntrys_dummy_token") }
  config.default_cassette_options = { record: :once, match_requests_on: [:method, :uri, :body] }
end

# Ensure coverage results are written at exit
if ENV["COVERAGE"]
  SimpleCov.at_exit do
    SimpleCov.result.format!
    coverage = SimpleCov.result.covered_percent
    puts "\nLine coverage: #{coverage.round(2)}%"
  end
end
