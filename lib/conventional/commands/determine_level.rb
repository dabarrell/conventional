# frozen_string_literal: true

module Conventional
  module Commands
    class DetermineLevel
      LEVELS = {
        0 => :major,
        1 => :minor,
        2 => :patch
      }

      def call(commits:, pre_major: false)
        level = 2

        commits.each do |commit|
          if !commit.breaking_change.nil?
            level = 0
          elsif %w[feat feature].include? commit.type
            level = 1 if level == 2
          end
        end

        level += 1 if pre_major && level < 2

        LEVELS[level]
      end
    end
  end
end
