# frozen_string_literal: true

require "dry-struct"
require "conventional/types"

module Conventional
  module Entities
    class Commit < Dry::Struct
      class Revert < Dry::Struct
        attribute :header, Types::String
        attribute :id, Types::String
      end

      attribute :id, Types::String
      attribute :header, Types::String
      attribute :body, Types::String.optional
      attribute :footer, Types::String.optional
      attribute :breaking_change, Types::String.optional
      attribute :type, Types::String.optional
      attribute :scope, Types::String.optional
      attribute :subject, Types::String.optional
      attribute :mentions, Types::Array.of(Types::Coercible::String)
      attribute :revert, Revert.optional
    end
  end
end
