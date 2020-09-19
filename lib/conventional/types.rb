# frozen_string_literal: true

require "dry-types"
require "rubygems/version"

module Conventional
  module Types
    include Dry.Types

    Version = Types.Instance(Gem::Version)
  end
end
