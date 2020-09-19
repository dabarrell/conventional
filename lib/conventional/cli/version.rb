# frozen_string_literal: true

require "dry/cli"
require "gem/release"

require "conventional/version"
require "conventional/utils"

module Conventional
  module CLI
    class Version < Dry::CLI::Command
      desc "Print version"

      def call(*)
        Utils.say Conventional::VERSION
      end
    end
  end
end
