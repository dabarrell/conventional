# frozen_string_literal: true

require "rubygems/version"

require "conventional/git/get_sem_ver_tags"
require "conventional/entities/tag"
require "conventional/utils"

RSpec.describe Conventional::Git::GetSemVerTags, "#call" do
  let(:prefix) { described_class::DEFAULT_PREFIX }

  before do
    allow(Conventional::Utils).to receive(:exec).with("git log --simplify-by-decoration --decorate --pretty=oneline").and_return(lines.join("\n"))
  end

  subject(:result) { described_class.new.call(prefix: prefix) }

  context "no commit history" do
    let(:lines) { [] }

    it "returns no tags" do
      expect(result).to eq([])
    end
  end

  context "commit history doesn't contain tags" do
    let(:lines) {
      [
        "bb3459f6288c092f82c621a863bef03414b463ad (HEAD -> specs) feat!: test",
        "a00cfb85cabbc29bb10ced3af958d7540b80e7a3 (origin/master, master) chore: release [skip ci]",
        "04d60a9869655b73e3b80ba726ba40de98e1022d feat: Test"
      ]
    }

    it "returns no tags" do
      expect(result).to eq([])
    end
  end

  context "commit history contains tags that don't match prefix" do
    let(:prefix) { "v" }
    let(:lines) {
      [
        "bb3459f6288c092f82c621a863bef03414b463ad (HEAD -> specs, tag: random) feat!: test",
        "a00cfb85cabbc29bb10ced3af958d7540b80e7a3 (tag: who-knows, origin/master, master) chore: release [skip ci]",
        "04d60a9869655b73e3b80ba726ba40de98e1022d (tag: vv1.0.0) feat: Test"
      ]
    }

    it "returns no tags" do
      expect(result).to eq([])
    end
  end

  context "commit history contains tags that match prefix but aren't semver" do
    let(:prefix) { "v" }
    let(:lines) {
      [
        "bb3459f6288c092f82c621a863bef03414b463ad (HEAD -> specs, tag: v123a.1.0.0.0) feat!: test",
        "a00cfb85cabbc29bb10ced3af958d7540b80e7a3 (tag: v1ab3, origin/master, master) chore: release [skip ci]",
        "04d60a9869655b73e3b80ba726ba40de98e1022d (tag: vThis-ain't-it) feat: Test"
      ]
    }

    it "returns no tags" do
      expect(Gem::Version).to receive(:correct?).with("123a.1.0.0.0")
      expect(Gem::Version).to receive(:correct?).with("1ab3")
      expect(Gem::Version).to receive(:correct?).with("This-ain't-it")
      expect(result).to eq([])
    end
  end

  context "commit history contains valid semver tags" do
    let(:prefix) { "v" }
    let(:lines) {
      [
        "bb3459f6288c092f82c621a863bef03414b463ad (HEAD -> specs, tag: v10.0.1.pre.alpha.1) feat!: test",
        "a00cfb85cabbc29bb10ced3af958d7540b80e7a3 (tag: v1, origin/master, master) chore: release [skip ci]",
        "04d60a9869655b73e3b80ba726ba40de98e1022d (tag: not-valid) feat: Test",
        "04d60a9869655b73e3b80ba726ba40de98e1022d (tag: v0.1.1) feat: Test",
        "04d60a9869655b73e3b80ba726ba40de98e1022d feat: Test"
      ]
    }

    it "returns only valid semver tags in reverse-chronological order" do
      expect(result).to match_array [
        an_object_having_attributes(
          class: Conventional::Entities::Tag,
          value: "v10.0.1.pre.alpha.1",
          version: an_object_having_attributes(
            class: Gem::Version,
            version: "10.0.1.pre.alpha.1"
          ),
          prefix: prefix
        ),
        an_object_having_attributes(
          class: Conventional::Entities::Tag,
          value: "v1",
          version: an_object_having_attributes(
            class: Gem::Version,
            version: "1"
          ),
          prefix: prefix
        ),
        an_object_having_attributes(
          class: Conventional::Entities::Tag,
          value: "v0.1.1",
          version: an_object_having_attributes(
            class: Gem::Version,
            version: "0.1.1"
          ),
          prefix: prefix
        )
      ]
    end
  end
end
