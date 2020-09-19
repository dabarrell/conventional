# frozen_string_literal: true

require "gem/release/cmds/bump"
require "gem/release/context"

require "conventional/commands/bump"

RSpec.describe Conventional::Commands::Bump, "#call" do
  let(:level) { :minor }
  let(:tag) { true }
  let(:dry_run) { false }
  let(:push) { true }
  let(:message) { "message!" }

  let(:gem_release_bump) { instance_spy(Gem::Release::Cmds::Bump) }

  subject(:run) { described_class.new.call(level: level, tag: tag, dry_run: dry_run, push: push, message: message) }

  it "calls gem release bump with provided arguments" do
    opts = {
      version: level.to_s,
      message: message,
      tag: tag,
      push: push,
      pretend: dry_run
    }

    expect(Gem::Release::Cmds::Bump).to receive(:new).with(an_instance_of(Gem::Release::Context), {}, opts).and_return(gem_release_bump)
    expect(gem_release_bump).to receive(:run)

    run
  end
end
