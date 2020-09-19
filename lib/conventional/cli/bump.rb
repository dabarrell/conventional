# frozen_string_literal: true

require "dry/cli"
require "gem/release"

require "conventional/git/parse_commit"
require "conventional/git/get_sem_ver_tags"
require "conventional/git/get_raw_commits"
require "conventional/commands/bump"
require "conventional/commands/determine_level"

module Conventional
  module CLI
    class Bump < Dry::CLI::Command
      desc "Bumps gem according to conventional commits"

      option :level, values: %w[patch minor major], desc: "The level of bump to execute (determined automatically if not provided)"
      option :tag, type: :boolean, default: true, desc: "Create and push git tag"
      option :message, type: :string, default: Conventional::Commands::Bump::DEFAULT_COMMIT_MESSAGE, desc: "Commit message template"
      option :dry_run, type: :boolean, default: false, desc: "Completes a dry run without making any changes"

      NoTagsFound = Class.new(StandardError)

      def initialize(
        get_sem_ver_tags: Conventional::Git::GetSemVerTags.new,
        get_raw_commits: Conventional::Git::GetRawCommits.new,
        parse_commit: Conventional::Git::ParseCommit.new,
        determine_level: Conventional::Commands::DetermineLevel.new,
        bump: Conventional::Commands::Bump.new
      )
        @get_sem_ver_tags = get_sem_ver_tags
        @get_raw_commits = get_raw_commits
        @parse_commit = parse_commit
        @bump = bump
        @determine_level = determine_level
        super()
      end

      def call(tag:, message:, dry_run:, level: nil, **)
        if level.nil?
          most_recent_tag = get_sem_ver_tags.call.first
          pre_major = most_recent_tag ? most_recent_tag.version < Gem::Version.new("1.0.0") : true
          raw_commits = get_raw_commits.call(from: most_recent_tag&.value)
          commits = raw_commits.map { |raw_commit| parse_commit.call(raw_commit: raw_commit) }
          level = determine_level.call(commits: commits, pre_major: pre_major)
        end

        bump.call(level: level, tag: tag, message: message, dry_run: dry_run)
      end

      private

      attr_reader :get_sem_ver_tags, :get_raw_commits, :parse_commit, :determine_level, :bump
    end
  end
end
