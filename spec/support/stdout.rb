# frozen_string_literal: true

require "stringio"

module RSpec
  module Support
    module Stdout
      private

      def with_captured_stdout
        original = $stdout
        captured = StringIO.new
        $stdout = captured
        yield
        $stdout.string
      ensure
        $stdout = original
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Support::Stdout
end
