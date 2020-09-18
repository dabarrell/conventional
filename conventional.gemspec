# frozen_string_literal: true

require "rake"

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "conventional/version"

Gem::Specification.new do |spec|
  spec.name = "conventional"
  spec.version = Conventional::VERSION.dup

  spec.authors = ["David Barrell"]
  spec.email = ["david@barrell.me"]
  spec.licenses = "MTI"

  spec.summary = "Utilities for working with conventional commits"
  spec.homepage = "https://github.com/dabarrell/conventional"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dabarrell/conventional"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.files = FileList[
    "exe/*",
    "lib/*.rb",
    "bin/*",
    "[A-Z]*",
    "spec/*"
  ].to_a

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "standard", "~> 0.6.0"
  spec.add_development_dependency "simplecov", "~> 0.17"
  spec.add_development_dependency "bundler-audit", "~> 0.6"

  spec.add_runtime_dependency "gem-release", "~> 2.1"
  spec.add_runtime_dependency "dry-cli", "~> 0.6.0"
  spec.add_runtime_dependency "dry-struct", "~> 1.3.0"
end
