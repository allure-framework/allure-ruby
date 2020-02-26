# frozen_string_literal: true

require "json"
require "fileutils"

require_relative "util"

class SimpleCovMerger
  extend TaskUtil

  class << self
    def merge_coverage(cc_resultset_json)
      ENV["COV_MERGE"] = "true"
      require "simplecov"
      require "simplecov-console"

      merge_results
      generate_cc_resultset(cc_resultset_json)
    end

    private

    def merge_results
      puts "Generating combined coverage report".yellow
      groups.each { |g| SimpleCov.add_group(g, g) }
      SimpleCov.collate(Dir["#{root}/*/coverage/.resultset.json"]) do
        formatter(multiformatter)
        minimum_coverage(95)
      end
    end

    def generate_cc_resultset(cc_resultset_json)
      resultset = JSON.parse(File.read("#{root}/coverage/.resultset.json"))
      primary_key = groups.join(", ")

      cc_resultset = resultset[primary_key]["coverage"].each_with_object({}) do |(k, v), h|
        h[k] = v["lines"]
      end

      File.write(cc_resultset_json, { primary_key => { "coverage" => cc_resultset } }.to_json, mode: "w")
    end

    def groups
      @groups ||= %w[allure-cucumber allure-rspec allure-ruby-commons]
    end

    def multiformatter
      [SimpleCov::Formatter::Console].yield_self do |formatters|
        formatters << SimpleCov::Formatter::HTMLFormatter if ENV["COV_HTML_REPORT"]
        SimpleCov::Formatter::MultiFormatter.new(formatters)
      end
    end
  end
end
