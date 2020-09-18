# frozen_string_literal: true

module Conventional
  module Git
    class ParseCommit
      HEADER_PATTERN = /^(?<type>\w*)(?:\((?<scope>.*)\))?!?: (?<subject>.*)$/i
      BREAKING_HEADER_PATTERN = /^(\w*)(?:\((.*)\))?!: (?<subject>.*)$/i
      BREAKING_CHANGE_NOTES_PATTERN = /^[\\s|*]*(BREAKING CHANGE)[:\\s]+(.*)/
      FIELD_PATTERN = /^-(.*?)-$/
      REVERT_PATTERN = /^(?:Revert|revert:)\s"?(?<header>[\s\S]+?)"?\s*This reverts commit (?<hash>\w*)\./i
      REVERT_CORRESPONDENCE = %w[header hash]
      MENTION_PATTERN = /@([\w-]+)/

      def call(raw_commit:)
        lines = trim_new_lines(raw_commit).split(/\r?\n+/)

        return nil if lines.empty?

        continue_note = false
        is_body = true

        body = nil
        footer = nil
        mentions = []
        notes = []
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

          # A new important note
          notes_match = line.match BREAKING_CHANGE_NOTES_PATTERN
          if notes_match
            continue_note = true
            is_body = false
            footer = append(footer, line)

            note = {
              title: notes_match[1],
              text: notes_match[2]
            }

            notes << note
            next
          end

          if continue_note
            notes[notes.length - 1][:text] = append(notes[notes.length - 1][:text], line)
            footer = append(footer, line)

            next
          end

          if is_body
            body = append(body, line)
          else
            footer = append(footer, line)
          end
        end

        if notes.empty?
          breaking_header_match = header.match BREAKING_HEADER_PATTERN
          if breaking_header_match
            note_text = breaking_header_match[:subject]
            notes << {
              title: "BREAKING CHANGE",
              text: note_text
            }
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

        notes.map! do |note|
          note[:text] = trim_new_lines(note[:text])
          note
        end

        {
          **header_parts,
          body: body ? trim_new_lines(body) : nil,
          footer: footer ? trim_new_lines(footer) : nil,
          header: header,
          mentions: mentions,
          notes: notes,
          revert: revert,
          **other_fields
        }
      end

      private

      def trim_new_lines(raw)
        raw.gsub(/\A(?:\r\n|\n|\r)+|(?:\r\n|\n|\r)+\z/, "")
      end

      def truncate_to_scissor(lines)
        scissor_index = lines.index(SCISSOR)

        return lines unless scissor_index

        lines.take(scissor_index)
      end

      def append(src, line)
        return line unless src
        src + "\n" + line
      end
    end
  end
end
