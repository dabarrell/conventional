# frozen_string_literal: true

require "conventional/utils"

module Conventional
  module Git
    class GetSemVerTags
      DEFAULT_PREFIX = "v"

      def call(prefix: DEFAULT_PREFIX)
        tags = []
        tag_regex = /tag:\s*(.+?)[,)]/i
        tag_prefix_regex = /^#{prefix}(.*)/

        data = Conventional::Utils.exec("git log --simplify-by-decoration --decorate --pretty=oneline")
        data.split("\n").each do |line|
          matches = line.scan(tag_regex).flatten
          next if matches.empty?

          matches.each do |tag|
            m = tag.match(tag_prefix_regex)
            tags << tag if m && Gem::Version.correct?(m[1])
          end
        end

        tags
      end
    end
  end
end
