# frozen_string_literal: true

require "simplecov"

suite = Test::Suite.instance

# Ensure appropriate names when running tests across multiple CI jobs
SimpleCov.command_name(suite.test_group_name) if suite.parallel?

SimpleCov.configure do
  enable_coverage :branch

  # Exclude test suite
  add_filter "/spec/"

  self.formatters = [SimpleCov::Formatter::HTMLFormatter]
end

SimpleCov.at_exit do
  # Don't fire if this is `rake spec` (by this point, the `rspec` command has
  # already run and formatted its coverage results, doing this again here will
  # overwrite them with an empty set)
  next if $0.end_with?("rake") && $ARGV[0].to_s.start_with?("spec")

  SimpleCov.result.format!
end
