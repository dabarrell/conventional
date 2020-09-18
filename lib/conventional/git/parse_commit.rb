# frozen_string_literal: true

require "conventional/entities/commit"

module Conventional
  module Git
    class ParseCommit
      HEADER_PATTERN = /^(?<type>\w*)(?:\((?<scope>.*)\))?!?: (?<subject>.*)$/i
      BREAKING_CHANGE_HEADER_PATTERN = /^(?:\w*)(?:\((?:.*)\))?!: (?<subject>.*)$/i
      BREAKING_CHANGE_BODY_PATTERN = /^[\\s|*]*(?:BREAKING CHANGE)[:\\s]+(?<contents>.*)/
      FIELD_PATTERN = /^-(.*?)-$/
      REVERT_PATTERN = /^(?:Revert|revert:)\s"?(?<header>[\s\S]+?)"?\s*This reverts commit (?<hash>\w*)\./i
      MENTION_PATTERN = /@([\w-]+)/

      def call(raw_commit:)
        header, *lines = trim_new_lines(raw_commit).split(/\r?\n+/)
        return nil if header.nil?

        contents = {
          body: nil,
          footer: nil,
          breaking_change: nil
        }

        initial_state = {
          current_processed_field: false,
          continue_breaking_change: false
        }

        contents, _ = lines.reduce([contents, initial_state]) { |input, line|
          acc, state = input
          next process_line(line, acc, state)
        }

        contents[:breaking_change] ||= match_breaking_change_header(header)

        contents = contents.transform_values { |v| trim_new_lines(v) }

        Conventional::Entities::Commit.new(
          **match_header_parts(header),
          **contents,
          header: header,
          mentions: match_mentions(raw_commit),
          revert: match_revert(raw_commit)
        )
      end

      private

      def process_line(line, contents, state)
        field_match = line.match FIELD_PATTERN
        if field_match
          state[:current_processed_field] = field_match[1]

          return [contents, state]
        end

        if state[:current_processed_field]
          contents[state[:current_processed_field].to_sym] = append(contents[state[:current_processed_field]], line)
          state[:current_processed_field] = false

          return [contents, state]
        end

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
        raw_commit.scan(MENTION_PATTERN).flatten
      end

      def match_revert(raw_commit)
        match = raw_commit.match REVERT_PATTERN
        {
          header: match ? match[:header] : nil,
          hash: match ? match[:hash] : nil
        }
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
