# frozen_string_literal: true

require "gem/release/cmds/bump"
require "gem/release/context"

module Conventional
  class Bump
    UnexpectedLevel = Class.new(StandardError)

    DEFAULT_COMMIT_MESSAGE = "chore: release [skip ci]"

    LEVELS = {
      0 => :major,
      1 => :minor,
      2 => :patch
    }

    def call(commits:)
      level = determine_level(commits)
      bump(level)
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

    def bump(level)
      opts = {
        version: level.to_s,
        message: DEFAULT_COMMIT_MESSAGE
      }
      Gem::Release::Cmds::Bump.new(Gem::Release::Context.new, {}, opts).run
    end
  end
end
