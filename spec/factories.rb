# frozen_string_literal: true

require "factory_bot"
require "rubygems/version"

require "conventional/entities/commit"
require "conventional/entities/tag"

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

FactoryBot.define do
  factory :tag, class: Conventional::Entities::Tag do
    initialize_with { new(attributes) }

    value { "v1.0.0" }
    version { Gem::Version.new(value.delete_prefix(prefix)) }
    prefix { "v" }
  end
end
