# frozen_string_literal: true

require "json"
require "fileutils"
require "simplecov_json_formatter"

require_relative "util"

class SimpleCovMerger
  extend TaskUtil

  class << self
    def merge_coverage
      ENV["COV_MERGE"] = "true"
      require "simplecov"
      require "simplecov-console"

      merge_results
    end

    private

    def merge_results
      puts "Generating combined coverage report".yellow
      groups.each { |g| SimpleCov.add_group(g, g) }
      SimpleCov.collate(Dir["#{root}/*/coverage/.resultset.json"]) do
        formatter(multiformatter)
        minimum_coverage(95)
        enable_coverage(:branch)
      end
    end

    def groups
      @groups ||= %w[allure-cucumber allure-rspec allure-ruby-commons]
    end

    def multiformatter
      [SimpleCov::Formatter::Console].then do |formatters|
        formatters << SimpleCov::Formatter::HTMLFormatter if ENV["COV_HTML_REPORT"]
        formatters << SimpleCov::Formatter::JSONFormatter if ENV["CC_TEST_REPORTER_ID"]
        SimpleCov::Formatter::MultiFormatter.new(formatters)
      end
    end
  end
end
