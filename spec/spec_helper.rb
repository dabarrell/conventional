# frozen_string_literal: true

require "bundler/setup"

require_relative "support/stdout"
require_relative "support/rspec"
require_relative "support/suite"
require_relative "support/simplecov"

suite = Test::Suite.instance
suite.start_coverage

# Eager load all lib/**/*.rb files to ensure simplecov detects them
Dir[File.join(suite.project_root, "lib", "**", "*.rb")].sort.each(&method(:require))
