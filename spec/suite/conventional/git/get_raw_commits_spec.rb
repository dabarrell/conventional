# frozen_string_literal: true

require "conventional/git/get_raw_commits"
require "conventional/utils"

RSpec.describe Conventional::Git::GetRawCommits, "#call" do
  let(:commits) { ["commit-1", "commit-2", "commit-3"] }
  let(:response) { commits.join("#{described_class::DELIMITER}\n") }

  subject(:result) { described_class.new.call(from: from, path: path) }

  context "from is nil" do
    let(:from) { nil }

    context "path is nil" do
      let(:path) { nil }

      it "executes git log command" do
        expect(Conventional::Utils).to receive(:exec).with(%(git log --date=short --format="%B%n-hash-%n%H%n#{described_class::DELIMITER}" HEAD)).and_return(response)
        expect(result).to match_array commits
      end
    end

    context "path is not nil" do
      let(:path) { "filepath/" }

      it "executes git log command" do
        expect(Conventional::Utils).to receive(:exec).with(%(git log --date=short --format="%B%n-hash-%n%H%n#{described_class::DELIMITER}" HEAD -- #{path})).and_return(response)
        expect(result).to match_array commits
      end
    end
  end

  context "from is not nil" do
    let(:from) { "v1.0.0" }

    context "path is nil" do
      let(:path) { nil }

      it "executes git log command" do
        expect(Conventional::Utils).to receive(:exec).with(%(git log --date=short --format="%B%n-hash-%n%H%n#{described_class::DELIMITER}" #{from}..HEAD)).and_return(response)
        expect(result).to match_array commits
      end
    end

    context "path is not nil" do
      let(:path) { "filepath/" }

      it "executes git log command" do
        expect(Conventional::Utils).to receive(:exec).with(%(git log --date=short --format="%B%n-hash-%n%H%n#{described_class::DELIMITER}" #{from}..HEAD -- #{path})).and_return(response)
        expect(result).to match_array commits
      end
    end
  end
end
