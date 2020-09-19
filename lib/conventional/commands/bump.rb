# frozen_string_literal: true

require "gem/release/cmds/bump"
require "gem/release/context"

module Conventional
  module Commands
    class Bump
      DEFAULT_COMMIT_MESSAGE = "chore: Release v%{version} [skip ci]"

      def call(level:, tag:, dry_run:, push:, message: DEFAULT_COMMIT_MESSAGE)
        opts = {
          version: level.to_s,
          message: message,
          tag: tag,
          push: push,
          pretend: dry_run
        }

        Gem::Release::Cmds::Bump.new(Gem::Release::Context.new, {}, opts).run
      end
    end
  end
end
