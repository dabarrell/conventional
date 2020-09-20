# frozen_string_literal: true

require "conventional/cli/recommended_bump"

RSpec.describe Conventional::CLI::RecommendedBump, "#call" do
  # Deps
  let(:get_sem_ver_tags) { instance_spy(Conventional::Git::GetSemVerTags) }
  let(:get_raw_commits) { instance_spy(Conventional::Git::GetRawCommits) }
  let(:parse_commit) { instance_spy(Conventional::Git::ParseCommit) }
  let(:determine_level) { instance_spy(Conventional::Commands::DetermineLevel) }

  let(:commits) {
    {
      "commit-1" => build(:commit),
      "commit-2" => build(:commit)
    }
  }

  subject(:run) {
    described_class
      .new(get_sem_ver_tags: get_sem_ver_tags, get_raw_commits: get_raw_commits, parse_commit: parse_commit, determine_level: determine_level)
      .call
  }

  context "most recent tag is pre_major" do
    let(:tags) { [build(:tag, value: "v0.2.0"), build(:tag, value: "v0.1.0")] }

    it "calls all commands with true pre_major" do
      expect(get_sem_ver_tags).to receive(:call).and_return(tags)
      expect(get_raw_commits).to receive(:call).with(from: "v0.2.0").and_return(commits.keys)
      commits.each_key { |raw_commit| expect(parse_commit).to receive(:call).with(raw_commit: raw_commit).and_return(commits[raw_commit]) }
      expect(determine_level).to receive(:call).with(commits: commits.values, pre_major: true, verbose: true)

      run
    end
  end

  context "most recent tag is not pre_major" do
    let(:tags) { [build(:tag, value: "v1.2.0"), build(:tag, value: "v1.1.0")] }

    it "calls all commands with false pre_major" do
      expect(get_sem_ver_tags).to receive(:call).and_return(tags)
      expect(get_raw_commits).to receive(:call).with(from: "v1.2.0").and_return(commits.keys)
      commits.each_key { |raw_commit| expect(parse_commit).to receive(:call).with(raw_commit: raw_commit).and_return(commits[raw_commit]) }
      expect(determine_level).to receive(:call).with(commits: commits.values, pre_major: false, verbose: true)

      run
    end
  end

  context "no valid tags found" do
    let(:tags) { [] }

    it "calls all commands with true pre_major" do
      expect(get_sem_ver_tags).to receive(:call).and_return(tags)
      expect(get_raw_commits).to receive(:call).with(from: nil).and_return(commits.keys)
      commits.each_key { |raw_commit| expect(parse_commit).to receive(:call).with(raw_commit: raw_commit).and_return(commits[raw_commit]) }
      expect(determine_level).to receive(:call).with(commits: commits.values, pre_major: true, verbose: true)

      run
    end
  end
end
