# frozen_string_literal: true

require "conventional/version"

RSpec.describe Conventional::VERSION do
  it "has a version" do
    expect(Conventional::VERSION).not_to be_nil
  end
end
