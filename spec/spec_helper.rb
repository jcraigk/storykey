# frozen_string_literal: true
require 'simplecov'
SimpleCov.start

require 'story_key'
require_relative 'support/shared_contexts/with_mocked_lexicon'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
