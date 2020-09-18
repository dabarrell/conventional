# frozen_string_literal: true

require "bundler/setup"

require_relative "support/stdout"
require_relative "support/rspec"
require_relative "support/suite"
require_relative "support/simplecov"

suite = Test::Suite.instance
suite.start_coverage
