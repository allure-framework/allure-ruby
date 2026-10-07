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
      %w[allure-cucumber allure-rspec allure-ruby-commons].each { |g| SimpleCov.group(g, g) }

      formatters = [SimpleCov::Formatter::Console]
      formatters << SimpleCov::Formatter::HTMLFormatter if ENV["COV_HTML_REPORT"]
      formatters << SimpleCov::Formatter::JSONFormatter if ENV["CC_TEST_REPORTER_ID"]

      SimpleCov.collate(Dir["#{root}/*/coverage/.resultset.json"]) do
        formatter(SimpleCov::Formatter::MultiFormatter.new(formatters))
        minimum_coverage(95)
        enable_coverage(:branch)
      end
    end
  end
end
