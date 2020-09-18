# frozen_string_literal: true

module Conventional
  module Git
    class ParseCommit
      HEADER_PATTERN = /^(?<type>\w*)(?:\((?<scope>.*)\))?!?: (?<subject>.*)$/i
      BREAKING_CHANGE_HEADER_PATTERN = /^(?:\w*)(?:\((?:.*)\))?!: (?<subject>.*)$/i
      BREAKING_CHANGE_BODY_PATTERN = /^[\\s|*]*(?:BREAKING CHANGE)[:\\s]+(?<contents>.*)/
      FIELD_PATTERN = /^-(.*?)-$/
      REVERT_PATTERN = /^(?:Revert|revert:)\s"?(?<header>[\s\S]+?)"?\s*This reverts commit (?<hash>\w*)\./i
      REVERT_CORRESPONDENCE = %w[header hash]
      MENTION_PATTERN = /@([\w-]+)/

      def call(raw_commit:)
        lines = trim_new_lines(raw_commit).split(/\r?\n+/)

        return nil if lines.empty?

        continue_breaking_change = false

        body = nil
        footer = nil
        mentions = []
        breaking_change = nil
        other_fields = {}

        header = lines.shift

        header_parts = extract_header_parts(header)

        current_processed_field = false

        # body or footer
        lines.each do |line|
          field_match = line.match FIELD_PATTERN
          if field_match
            current_processed_field = field_match[1]

            next
          end

          if current_processed_field
            other_fields[current_processed_field.to_sym] = append(other_fields[current_processed_field], line)
            current_processed_field = false

            next
          end

          breaking_change ||= check_breaking_change_body(line)

          if breaking_change
            breaking_change = append(breaking_change, line) if continue_breaking_change

            continue_breaking_change = true
            footer = append(footer, line)
            next
          end

          body = append(body, line)
        end

        breaking_change ||= check_breaking_change_header(header)

        mentions.concat(extract_mentions(raw_commit))

        revert = check_revert(raw_commit)

        {
          **header_parts,
          body: body ? trim_new_lines(body) : nil,
          footer: footer ? trim_new_lines(footer) : nil,
          header: header,
          mentions: mentions,
          breaking_change: breaking_change ? trim_new_lines(breaking_change) : nil,
          revert: revert,
          **other_fields
        }
      end

      private

      def extract_header_parts(header)
        header_match = header.match HEADER_PATTERN
        {
          type: header_match ? header_match[:type] : nil,
          scope: header_match ? header_match[:scope] : nil,
          subject: header_match ? header_match[:subject] : nil
        }
      end

      def check_breaking_change_body(line)
        match = line.match BREAKING_CHANGE_BODY_PATTERN
        match[:contents] || "" if match
      end

      def check_breaking_change_header(header)
        match = header.match BREAKING_CHANGE_HEADER_PATTERN
        match[:subject] if match
      end

      def extract_mentions(raw_commit)
        raw_commit.scan(MENTION_PATTERN).flatten
      end

      def check_revert(raw_commit)
        match = raw_commit.match REVERT_PATTERN
        {
          header: match ? match[:header] : nil,
          hash: match ? match[:hash] : nil
        }
      end

      def trim_new_lines(raw)
        raw.gsub(/\A(?:\r\n|\n|\r)+|(?:\r\n|\n|\r)+\z/, "")
      end

      def append(src, line)
        return line unless src
        src + "\n" + line
      end
    end
  end
end
