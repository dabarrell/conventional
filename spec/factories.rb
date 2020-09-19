# frozen_string_literal: true

require "factory_bot"

require "conventional/entities/commit"

FactoryBot.define do
  factory :commit, class: Conventional::Entities::Commit do
    initialize_with { new(attributes) }

    header { "#{type}(#{scope}): Commit message" }
    body { nil }
    footer { nil }
    breaking_change { nil }
    type { nil }
    scope { nil }
    subject { nil }
    hash { nil }
    mentions { [] }
    revert { nil }

    trait :breaking_change do
      breaking_change { "Details about a breaking change" }
      type { "feat" }
    end

    trait :feat do
      type { "feat" }
    end

    trait :chore do
      type { "chore" }
    end

    trait :fix do
      type { "fix" }
    end
  end
end
