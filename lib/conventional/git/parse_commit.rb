# frozen_string_literal: true

require "dry-struct"
require "conventional/entities/commit"

module Conventional
  module Git
    class ParseCommit
      InvalidRawCommit = Class.new(StandardError)

      HEADER_PATTERN = /^(?<type>\w*)(?:\((?<scope>.*)\))?!?: (?<subject>.*)$/i
      BREAKING_CHANGE_HEADER_PATTERN = /^(?:\w*)(?:\((?:.*)\))?!: (?<subject>.*)$/i
      BREAKING_CHANGE_BODY_PATTERN = /^[\\s|*]*(?:BREAKING CHANGE)[:\\s]+(?<contents>.*)/
      REVERT_PATTERN = /^(?:Revert|revert:)\s"?(?<header>[\s\S]+?)"?\s*This reverts commit (?<id>\w*)\./i
      MENTION_PATTERN = /@([\w-]+)/

      def call(raw_commit:)
        raise InvalidRawCommit unless raw_commit.is_a?(String)

        id, header, *lines = trim_new_lines(raw_commit).split(/\r?\n+/)
        raise InvalidRawCommit if id.nil? || header.nil?

        Conventional::Entities::Commit.new(
          id: id,
          **match_header_parts(header),
          **extract_contents(header, lines),
          header: header,
          mentions: match_mentions(raw_commit),
          revert: match_revert(raw_commit)
        )
      end

      private

      def extract_contents(header, lines)
        contents = {
          body: nil,
          footer: nil,
          breaking_change: nil
        }

        initial_state = {
          continue_breaking_change: false
        }

        contents, _ = lines.reduce([contents, initial_state]) { |input, line|
          acc, state = input
          next process_line(line, acc, state)
        }

        contents[:breaking_change] ||= match_breaking_change_header(header)

        contents.transform_values { |v| trim_new_lines(v) }
      end

      def process_line(line, contents, state)
        contents[:breaking_change] ||= match_breaking_change_body(line)

        if contents[:breaking_change]
          contents[:breaking_change] = append(contents[:breaking_change], line) if state[:continue_breaking_change]

          state[:continue_breaking_change] = true
          contents[:footer] = append(contents[:footer], line)
          return [contents, state]
        end

        contents[:body] = append(contents[:body], line)

        [contents, state]
      end

      def match_header_parts(header)
        header_match = header.match HEADER_PATTERN
        {
          type: header_match ? header_match[:type] : nil,
          scope: header_match ? header_match[:scope] : nil,
          subject: header_match ? header_match[:subject] : nil
        }
      end

      def match_breaking_change_body(line)
        match = line.match BREAKING_CHANGE_BODY_PATTERN
        match[:contents] || "" if match
      end

      def match_breaking_change_header(header)
        match = header.match BREAKING_CHANGE_HEADER_PATTERN
        match[:subject] if match
      end

      def match_mentions(raw_commit)
        raw_commit.scan(MENTION_PATTERN).flatten.uniq
      end

      def match_revert(raw_commit)
        match = raw_commit.match REVERT_PATTERN
        if match
          {
            header: match[:header],
            id: match[:id]
          }
        end
      end

      def trim_new_lines(raw)
        raw&.gsub(/\A(?:\r\n|\n|\r)+|(?:\r\n|\n|\r)+\z/, "")
      end

      def append(src, line)
        return line unless src
        src + "\n" + line
      end
    end
  end
end
