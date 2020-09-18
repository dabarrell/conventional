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
        is_body = true

        body = nil
        footer = nil
        mentions = []
        breaking_change = nil
        other_fields = {}

        header = lines.shift

        header_match = header.match HEADER_PATTERN
        header_parts = header_match ? {
          type: header_match[:type],
          scope: header_match[:scope],
          subject: header_match[:subject]
        } : {
          type: nil,
          scope: nil,
          subject: nil
        }

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

            next
          end

          breaking_change_match = line.match BREAKING_CHANGE_BODY_PATTERN
          if breaking_change_match
            continue_breaking_change = true
            is_body = false
            footer = append(footer, line)

            breaking_change = breaking_change_match[:contents]
            next
          end

          if continue_breaking_change
            breaking_change = append(breaking_change, line)
            footer = append(footer, line)

            next
          end

          if is_body
            body = append(body, line)
          else
            footer = append(footer, line)
          end
        end

        if breaking_change.nil?
          breaking_header_match = header.match BREAKING_CHANGE_HEADER_PATTERN
          if breaking_header_match
            breaking_change = breaking_header_match[:subject]
          end
        end

        mentions_matches = raw_commit.scan(MENTION_PATTERN).flatten
        mentions.concat(mentions_matches)

        revert_match = raw_commit.match REVERT_PATTERN
        revert = revert_match ? {
          header: revert_match[:header],
          hash: revert_match[:hash]
        } : {
          header: nil,
          hash: nil
        }

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
