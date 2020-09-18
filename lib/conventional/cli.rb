# frozen_string_literal: true

require "dry/cli"
require "gem/release"

require_relative "cli/version"
require_relative "cli/bump"

module Conventional
  module CLI
    extend Dry::CLI::Registry

    register "version", Version, aliases: %w[v -v --version]
    register "bump", Bump, aliases: %w[b]
  end
end
