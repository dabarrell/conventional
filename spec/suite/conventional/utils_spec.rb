# frozen_string_literal: true

require "open3"

require "conventional/utils"

RSpec.describe Conventional::Utils do
  describe ".exec" do
    let(:output) { "test" }
    let(:status) { instance_spy(Process::Status) }

    before do
      allow(status).to receive(:success?).and_return(success?)
      allow(Open3).to receive(:capture2).and_return([output, status])
    end

    context "command is successfully executed" do
      let(:success?) { true }

      it "returns output" do
        expect(described_class.exec("command")).to eq(output)
      end
    end

    context "command is unsuccessfully executed" do
      let(:success?) { false }

      it "throws CommandFailed" do
        expect { described_class.exec("command") }.to raise_error(described_class::CommandFailed)
      end
    end
  end

  describe ".say" do
    let(:message) { "message" }

    it "puts message" do
      expect(described_class).to receive(:puts).with(message)
      described_class.say(message)
    end
  end
end
