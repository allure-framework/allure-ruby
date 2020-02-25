# frozen_string_literal: true

require "json"
require "fileutils"

require_relative "util"

class SimpleCovMerger
  extend TaskUtil

  class << self
    def merge_coverage
      ENV["COV_MERGE"] = "true"
      require "simplecov"
      require "simplecov-console"

      SimpleCov.configure do
        %w[allure-cucumber allure-rspec allure-ruby-commons].each { |g| add_group(g, g) }
        formatter(multiformatter)
        minimum_coverage(95)
      end

      merge_results
    end

    private

    def merge_results
      puts "Generating combined coverage report".yellow
      results = Dir.glob("#{root}/*/coverage/.resultset.json").each_with_object([]) do |file, res|
        res << SimpleCov::Result.from_hash(JSON.parse(File.read(file)))
      end
      SimpleCov::ResultMerger.merge_results(*results).tap do |result|
        SimpleCov::ResultMerger.store_result(result)
        result.format!
      end
    end

    def multiformatter
      [SimpleCov::Formatter::Console].yield_self do |formatters|
        formatters << SimpleCov::Formatter::HTMLFormatter if ENV["COV_HTML_REPORT"]
        SimpleCov::Formatter::MultiFormatter.new(formatters)
      end
    end
  end
end
