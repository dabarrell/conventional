# frozen_string_literal: true

require "dry-struct"
require "conventional/types"

module Conventional
  module Entities
    class Tag < Dry::Struct
      attribute :value, Types::String
      attribute :version, Types::Version
      attribute :prefix, Types::String.optional
    end
  end
end
