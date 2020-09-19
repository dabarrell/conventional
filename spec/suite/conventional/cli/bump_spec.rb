# frozen_string_literal: true

require "conventional/cli/bump"
require "conventional/commands/bump"

RSpec.describe Conventional::CLI::Bump, "#call" do
  # Options
  let(:tag) { true }
  let(:message) { Conventional::Commands::Bump::DEFAULT_COMMIT_MESSAGE }
  let(:dry_run) { false }
  let(:push) { true }

  # Deps
  let(:get_sem_ver_tags) { instance_spy(Conventional::Git::GetSemVerTags) }
  let(:get_raw_commits) { instance_spy(Conventional::Git::GetRawCommits) }
  let(:parse_commit) { instance_spy(Conventional::Git::ParseCommit) }
  let(:determine_level) { instance_spy(Conventional::Commands::DetermineLevel) }
  let(:bump) { instance_spy(Conventional::Commands::Bump) }

  subject(:run) {
    described_class
      .new(get_sem_ver_tags: get_sem_ver_tags, get_raw_commits: get_raw_commits, parse_commit: parse_commit, determine_level: determine_level, bump: bump)
      .call(tag: tag, message: message, dry_run: dry_run, push: push, level: level)
  }

  context "level is provided" do
    let(:level) { "major" }

    it "only calls bump" do
      expect(get_sem_ver_tags).not_to receive(:call)
      expect(get_raw_commits).not_to receive(:call)
      expect(parse_commit).not_to receive(:call)
      expect(determine_level).not_to receive(:call)
      expect(bump).to receive(:call).with(level: level, tag: tag, message: message, push: push, dry_run: dry_run)

      run
    end
  end

  context "level is not provided" do
    let(:level) { nil }
    let(:commits) {
      {
        "commit-1" => build(:commit),
        "commit-2" => build(:commit)
      }
    }

    context "most recent tag is pre_major" do
      let(:tags) { [build(:tag, value: "v0.2.0"), build(:tag, value: "v0.1.0")] }

      it "calls all commands with true pre_major" do
        expect(get_sem_ver_tags).to receive(:call).and_return(tags)
        expect(get_raw_commits).to receive(:call).with(from: "v0.2.0").and_return(commits.keys)
        commits.each_key { |raw_commit| expect(parse_commit).to receive(:call).with(raw_commit: raw_commit).and_return(commits[raw_commit]) }
        expect(determine_level).to receive(:call).with(commits: commits.values, pre_major: true).and_return(:minor)
        expect(bump).to receive(:call).with(level: :minor, tag: tag, message: message, push: push, dry_run: dry_run)

        run
      end
    end

    context "most recent tag is not pre_major" do
      let(:tags) { [build(:tag, value: "v1.2.0"), build(:tag, value: "v1.1.0")] }

      it "calls all commands with false pre_major" do
        expect(get_sem_ver_tags).to receive(:call).and_return(tags)
        expect(get_raw_commits).to receive(:call).with(from: "v1.2.0").and_return(commits.keys)
        commits.each_key { |raw_commit| expect(parse_commit).to receive(:call).with(raw_commit: raw_commit).and_return(commits[raw_commit]) }
        expect(determine_level).to receive(:call).with(commits: commits.values, pre_major: false).and_return(:minor)
        expect(bump).to receive(:call).with(level: :minor, tag: tag, message: message, push: push, dry_run: dry_run)

        run
      end
    end

    context "no valid tags found" do
      let(:tags) { [] }

      it "calls all commands with true pre_major" do
        expect(get_sem_ver_tags).to receive(:call).and_return(tags)
        expect(get_raw_commits).to receive(:call).with(from: nil).and_return(commits.keys)
        commits.each_key { |raw_commit| expect(parse_commit).to receive(:call).with(raw_commit: raw_commit).and_return(commits[raw_commit]) }
        expect(determine_level).to receive(:call).with(commits: commits.values, pre_major: true).and_return(:minor)
        expect(bump).to receive(:call).with(level: :minor, tag: tag, message: message, push: push, dry_run: dry_run)

        run
      end
    end
  end
end
