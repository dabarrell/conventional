# frozen_string_literal: true

require "conventional/commands/determine_level"

RSpec.describe Conventional::Commands::DetermineLevel, "#call" do
  subject(:result) { described_class.new.call(commits: commits, pre_major: pre_major) }

  context "version is not pre-major" do
    let(:pre_major) { false }

    context "commits is empty" do
      let(:commits) { [] }

      it "returns patch" do
        expect(result).to eq(:patch)
      end
    end

    context "commits contains no features or breaking changes" do
      let(:commits) { [build(:commit, :chore), build(:commit, :fix)] }

      it "returns patch" do
        expect(result).to eq(:patch)
      end
    end

    context "commits contains a feature and a chore" do
      let(:commits) { [build(:commit, :chore), build(:commit, :feat)] }

      it "returns minor" do
        expect(result).to eq(:minor)
      end
    end

    context "commits contains multiple features" do
      let(:commits) { [build(:commit, :feat), build(:commit, :feat)] }

      it "returns minor" do
        expect(result).to eq(:minor)
      end
    end

    context "commits contains a breaking change" do
      let(:commits) { [build(:commit, :chore), build(:commit, :breaking_change)] }

      it "returns major" do
        expect(result).to eq(:major)
      end
    end
  end

  context "version is pre-major (less than 1.0.0)" do
    let(:pre_major) { true }

    context "commits contains a breaking change" do
      let(:commits) { [build(:commit, :chore), build(:commit, :breaking_change)] }

      it "returns minor" do
        expect(result).to eq(:minor)
      end
    end

    context "commits contains a feature" do
      let(:commits) { [build(:commit, :feat), build(:commit, :chore)] }

      it "returns patch" do
        expect(result).to eq(:patch)
      end
    end

    context "commits contains no features or breaking changes" do
      let(:commits) { [build(:commit), build(:commit, :fix)] }

      it "returns patch" do
        expect(result).to eq(:patch)
      end
    end
  end
end
