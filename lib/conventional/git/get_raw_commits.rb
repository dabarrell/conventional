# frozen_string_literal: true

module Conventional
  module Git
    class GetRawCommits
      DELIMITER = "///////////////////////////////////////////////"
      FORMAT = "%B%n-hash-%n%H"

      def call(from: nil, path: nil)
        cmd = ["git log --date=short"]
        cmd << %(--format="#{FORMAT}%n#{DELIMITER}")
        cmd << [from, "HEAD"].filter { |s| !s.nil? }.join("..")
        cmd << "-- #{path}" if path

        data = Utils.exec(cmd.join(" "))
        data.split("#{DELIMITER}\n")
      end
    end
  end
end
