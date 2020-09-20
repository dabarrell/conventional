# frozen_string_literal: true

require "conventional/utils"

module Conventional
  module Commands
    class DetermineLevel
      LEVELS = {
        0 => :major,
        1 => :minor,
        2 => :patch
      }

      def call(commits:, pre_major: false, verbose: false)
        level = 2
        breaking_changes = 0
        features = 0

        commits.each do |commit|
          if !commit.breaking_change.nil?
            level = 0
            breaking_changes += 1
          elsif ["feat", "feature"].include? commit.type
            level = 1 if level == 2
            features += 1
          end
        end

        level += 1 if pre_major && level < 2

        recommendation = LEVELS[level]

        if verbose
          details = []
          details << "#{breaking_changes} breaking changes"
          details << "#{features} features"
          details << "pre-major" if pre_major
          Utils.say("Recommended version bump: #{recommendation} (#{details.join(", ")})")
        end
        recommendation
      end
    end
  end
end
