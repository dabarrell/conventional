# frozen_string_literal: true

require "json"
require "pathname"
require "rspec"

module Test
  module SuiteHelpers
    module_function

    def suite
      @suite ||= RSpec.configuration.suite
    end
  end

  class Suite
    class << self
      def instance
        @instance ||= new
      end
    end

    SUITE_PATH = "spec/suite"

    attr_reader :root, :project_root

    def initialize(root: nil)
      @root = root ? Pathname(root) : Pathname(Dir.pwd).join(SUITE_PATH).freeze
      @project_root = Pathname(Dir.pwd)
    end

    def start_coverage
      if coverage?
        require_relative "simplecov"
        SimpleCov.start
      end
    end

    def coverage_threshold
      ENV.fetch("COVERAGE_THRESHOLD").to_f.round
    end

    def current_coverage
      data = JSON.parse(File.open(project_root.join("coverage/.last_run.json")).read)
      data.fetch("result").fetch("covered_percent").to_f.round
    end

    def test_group_name
      @test_group_name ||= "test_suite_#{build_idx}"
    end

    def chdir(name)
      self.class.new(
        root: root.join(name.to_s)
      )
    end

    def files
      dirs.map { |dir| dir.join("**/*_spec.rb") }.flat_map { |path| Dir[path] }.sort
    end

    def groups
      dirs.map(&:basename).map(&:to_s).map(&:to_sym).sort
    end

    def dirs
      Dir[root.join("*")].map(&Kernel.method(:Pathname)).select(&:directory?)
    end

    def ci?
      !ENV["CI"].nil?
    end

    def parallel?
      ENV["CI_NODE_TOTAL"].to_i > 1
    end

    def build_idx
      ENV.fetch("CI_NODE_INDEX", -1).to_i
    end

    def coverage?
      ENV["COVERAGE"] == "true"
    end

    def log_dir
      Pathname(project_root).join("log")
    end

    def tmp_dir
      Pathname(project_root).join("tmp")
    end
  end
end

RSpec.configure do |config|
  ## Suite

  config.add_setting :suite
  config.suite = Test::Suite.new
  config.include Test::SuiteHelpers

  ## Derived metadata

  config.define_derived_metadata file_path: %r{/suite/} do |metadata|
    metadata[:group] = metadata[:file_path]
      .split("/")
      .then { |parts| parts[parts.index("suite") + 1] }
      .to_sym
  end

  # Add more derived metadata rules here, e.g.
  #
  # config.define_derived_metadata type: :request do |metadata|
  #   metadata[:db] = true
  # end
  #
  # config.define_derived_metadata :db do |metadata|
  #   metadata[:factory] = true unless metadata.key?(:factory)
  # end

  config.suite.groups.each do |group|
    config.when_first_matching_example_defined group: group do
      require_relative group.to_s
    rescue LoadError # rubocop:disable Lint/SuppressedException
    end
  end
end
