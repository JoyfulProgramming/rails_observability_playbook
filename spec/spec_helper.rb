# frozen_string_literal: true

require 'support/vcr'
require 'support/logging/test_helper'
require 'super_diff/rspec-rails'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.order = :random
end

SuperDiff.configure do |config|
  config.key_enabled = false
  config.diff_elision_enabled = false
  config.diff_elision_maximum = 3
  config.actual_color = :green
  config.expected_color = :red
  config.border_color = :yellow
  config.header_color = :yellow
end
