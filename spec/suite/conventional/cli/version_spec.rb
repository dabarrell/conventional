# frozen_string_literal: true

require "conventional/version"
require "conventional/utils"
require "conventional/cli/version"

RSpec.describe Conventional::CLI::Version, "#call" do
  subject(:run) { described_class.new.call }

  it "says version when called" do
    expect(Conventional::Utils).to receive(:say).with(Conventional::VERSION)

    run
  end
end
