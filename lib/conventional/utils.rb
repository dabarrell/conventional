# frozen_string_literal: true

require "open3"

module Conventional
  module Utils
    CommandFailed = Class.new(StandardError)

    def self.exec(cmd, **opts)
      output, status = Open3.capture2(cmd, **opts)

      raise CommandFailed unless status.success?
      output
    end

    def self.say(message)
      puts(message)
    end
  end
end
