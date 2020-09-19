# frozen_string_literal: true

require "conventional/entities/commit"
require "conventional/git/parse_commit"

RSpec.describe Conventional::Git::ParseCommit, "#call" do
  subject(:result) { described_class.new.call(raw_commit: raw_commit) }

  context "raw_commit is nil" do
    let(:raw_commit) { nil }

    it "raises error" do
      expect { result }.to raise_error(described_class::InvalidRawCommit)
    end
  end

  context "raw_commit is empty string" do
    let(:raw_commit) { "" }

    it "raises error" do
      expect { result }.to raise_error(described_class::InvalidRawCommit)
    end
  end

  context "raw_commit does not match the expected format" do
    let(:raw_commit) { "This is just a string" }

    it "raises error" do
      expect { result }.to raise_error(described_class::InvalidRawCommit)
    end
  end

  context "raw_commit is just a header" do
    let(:raw_commit) { generate_raw_commit(header: "Did the thing") }

    it "return valid commit" do
      expect(result).to have_attributes(
        class: Conventional::Entities::Commit,
        header: "Did the thing",
        id: "a034f2b97fc4b50c48e9874809cc933b0a705989",
        body: nil,
        footer: nil,
        breaking_change: nil,
        type: nil,
        scope: nil,
        subject: nil,
        mentions: [],
        revert: nil
      )
    end
  end

  context "raw_commit has a type but no scope" do
    let(:raw_commit) { generate_raw_commit(header: "feat: Did the thing") }

    it "return valid commit" do
      expect(result).to have_attributes(
        class: Conventional::Entities::Commit,
        header: "feat: Did the thing",
        id: "a034f2b97fc4b50c48e9874809cc933b0a705989",
        body: nil,
        footer: nil,
        breaking_change: nil,
        type: "feat",
        scope: nil,
        subject: "Did the thing",
        mentions: [],
        revert: nil
      )
    end
  end

  context "raw_commit has a type and scope" do
    let(:raw_commit) { generate_raw_commit(header: "feat(scope): Did the thing") }

    it "return valid commit" do
      expect(result).to have_attributes(
        class: Conventional::Entities::Commit,
        header: "feat(scope): Did the thing",
        id: "a034f2b97fc4b50c48e9874809cc933b0a705989",
        body: nil,
        footer: nil,
        breaking_change: nil,
        type: "feat",
        scope: "scope",
        subject: "Did the thing",
        mentions: [],
        revert: nil
      )
    end
  end

  context "raw_commit has a type and scope" do
    let(:raw_commit) { generate_raw_commit(header: "feat(scope): Did the thing") }

    it "return valid commit" do
      expect(result).to have_attributes(
        class: Conventional::Entities::Commit,
        header: "feat(scope): Did the thing",
        id: "a034f2b97fc4b50c48e9874809cc933b0a705989",
        body: nil,
        footer: nil,
        breaking_change: nil,
        type: "feat",
        scope: "scope",
        subject: "Did the thing",
        mentions: [],
        revert: nil
      )
    end
  end

  context "raw_commit has a breaking change header but no body" do
    let(:raw_commit) { generate_raw_commit(header: "feat(scope)!: Did the thing") }

    it "return valid commit" do
      expect(result).to have_attributes(
        class: Conventional::Entities::Commit,
        header: "feat(scope)!: Did the thing",
        id: "a034f2b97fc4b50c48e9874809cc933b0a705989",
        body: nil,
        footer: nil,
        breaking_change: "Did the thing",
        type: "feat",
        scope: "scope",
        subject: "Did the thing",
        mentions: [],
        revert: nil
      )
    end
  end

  context "raw_commit has a body with mentions" do
    let(:raw_commit) {
      generate_raw_commit(
        header: "feat(scope): Did the thing",
        lines: [
          "This is just a normal body",
          "",
          "with some extra lines for my boy @travolta",
          "an extra @travolta",
          ""
        ]
      )
    }

    it "return valid commit" do
      expect(result).to have_attributes(
        class: Conventional::Entities::Commit,
        header: "feat(scope): Did the thing",
        id: "a034f2b97fc4b50c48e9874809cc933b0a705989",
        body: "This is just a normal body\nwith some extra lines for my boy @travolta\nan extra @travolta",
        footer: nil,
        breaking_change: nil,
        type: "feat",
        scope: "scope",
        subject: "Did the thing",
        mentions: ["travolta"],
        revert: nil
      )
    end
  end

  context "raw_commit has a breaking change in the body" do
    let(:raw_commit) {
      generate_raw_commit(
        header: "feat(scope): Did the thing",
        lines: [
          "This is just a normal body",
          "BREAKING CHANGE:",
          "This is the breaking change"
        ]
      )
    }

    it "return valid commit" do
      expect(result).to have_attributes(
        class: Conventional::Entities::Commit,
        header: "feat(scope): Did the thing",
        id: "a034f2b97fc4b50c48e9874809cc933b0a705989",
        body: "This is just a normal body",
        footer: "BREAKING CHANGE:\nThis is the breaking change",
        breaking_change: "This is the breaking change",
        type: "feat",
        scope: "scope",
        subject: "Did the thing",
        mentions: [],
        revert: nil
      )
    end
  end

  context "raw_commit has a revert in the body" do
    let(:raw_commit) {
      generate_raw_commit(
        header: 'revert: "This is the commit message for a previous commit"',
        lines: [
          "This reverts commit 123423135."
        ]
      )
    }

    it "return valid commit" do
      expect(result).to have_attributes(
        class: Conventional::Entities::Commit,
        header: 'revert: "This is the commit message for a previous commit"',
        id: "a034f2b97fc4b50c48e9874809cc933b0a705989",
        body: "This reverts commit 123423135.",
        footer: nil,
        breaking_change: nil,
        type: "revert",
        scope: nil,
        subject: '"This is the commit message for a previous commit"',
        mentions: [],
        revert: an_object_having_attributes(
          class: Conventional::Entities::Commit::Revert,
          header: "This is the commit message for a previous commit",
          id: "123423135"
        )
      )
    end
  end

  # Produces a string similar to the following:
  #   a034f2b97fc4b50c48e9874809cc933b0a705989
  #   <header>
  #   <body (multiple lines)>
  def generate_raw_commit(header:, lines: [])
    components = []

    components << "a034f2b97fc4b50c48e9874809cc933b0a705989"
    components << header
    components.concat(lines)
    components.join("\n") + "\n"
  end
end
