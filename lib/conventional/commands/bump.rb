# frozen_string_literal: true

require "gem/release/cmds/bump"
require "gem/release/context"

module Conventional
  module Commands
    class Bump
      UnexpectedLevel = Class.new(StandardError)

      DEFAULT_COMMIT_MESSAGE = "chore: Release v%{version} [skip ci]"

      LEVELS = {
        0 => :major,
        1 => :minor,
        2 => :patch
      }

      def call(commits:, tag:, dry_run:, message: DEFAULT_COMMIT_MESSAGE)
        level = determine_level(commits)
        bump(level, tag, message, dry_run)
      end

      private

      def determine_level(commits)
        level = 2

        commits.each do |commit|
          if !commit.breaking_change.nil?
            level = 0
          elsif %w[feat feature].include? commit.type
            level = 1 if level == 2
          end
        end

        LEVELS[level]
      end

      def bump(level, tag, message, dry_run)
        opts = {
          version: level.to_s,
          message: message,
          tag: tag,
          pretend: dry_run
        }
        Gem::Release::Cmds::Bump.new(Gem::Release::Context.new, {}, opts).run
      end
    end
  end
end
