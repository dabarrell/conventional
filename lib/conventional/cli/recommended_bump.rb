# frozen_string_literal: true

require "dry/cli"
require "gem/release"

require "conventional/git/parse_commit"
require "conventional/git/get_sem_ver_tags"
require "conventional/git/get_raw_commits"
require "conventional/commands/determine_level"
require "conventional/utils"

module Conventional
  module CLI
    class RecommendedBump < Dry::CLI::Command
      desc "Returns the recommended bump level according to conventional commits"

      def initialize(
        get_sem_ver_tags: Conventional::Git::GetSemVerTags.new,
        get_raw_commits: Conventional::Git::GetRawCommits.new,
        parse_commit: Conventional::Git::ParseCommit.new,
        determine_level: Conventional::Commands::DetermineLevel.new
      )
        @get_sem_ver_tags = get_sem_ver_tags
        @get_raw_commits = get_raw_commits
        @parse_commit = parse_commit
        @determine_level = determine_level
        super()
      end

      def call(**)
        most_recent_tag = get_sem_ver_tags.call.first
        pre_major = most_recent_tag ? most_recent_tag.version < Gem::Version.new("1.0.0") : true
        raw_commits = get_raw_commits.call(from: most_recent_tag&.value)
        commits = raw_commits.map { |raw_commit| parse_commit.call(raw_commit: raw_commit) }
        determine_level.call(commits: commits, pre_major: pre_major, verbose: true)
      end

      private

      attr_reader :get_sem_ver_tags, :get_raw_commits, :parse_commit, :determine_level
    end
  end
end
