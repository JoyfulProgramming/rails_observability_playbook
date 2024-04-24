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

  config.backtrace_exclusion_patterns << %r{/gems/}
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.order = :random
end

SuperDiff.configure do |config|
  config.key_enabled = false
  config.diff_elision_enabled = true
  config.diff_elision_maximum = 3
  config.actual_color = :green
  config.expected_color = :red
  config.border_color = :yellow
  config.header_color = :yellow
end

RSpec::Matchers.define :include_payload do |expected|
  match do |actual|
    matcher = lambda do |(key, value)|
      if value.is_a?(Regexp)
        actual[key] =~ value
      else
        actual[key] == value
      end
    end
    expected.all?(&matcher)
  end

  description do
    "include payload #{expected}"
  end

  failure_message do |actual|
    matcher = lambda do |key, value|
      if value.is_a?(Regexp)
        actual[key] =~ value
      else
        actual[key] == value
      end
    end
    differences = expected.reject(&matcher).to_h
    "Expected to include payload but did not. Differences:\n\n#{SuperDiff::Differs::Main.call(actual.slice(*differences.keys), differences)}"
  end

  failure_message_when_negated do |actual|
    'N/A'
  end
end
