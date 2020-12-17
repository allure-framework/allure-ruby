# frozen_string_literal: true

require "logger"
require "singleton"

module Allure
  # Allure configuration class
  class Config
    include Singleton

    # @return [Array<String>] valid log levels
    LOGLEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze
    # @return [String] test plan path env var name
    TESTPLAN_PATH = "ALLURE_TESTPLAN_PATH"
    # @return [String] test plan file name
    TESTPLAN_JSON = "testplan.json"

    attr_accessor :results_directory, :logging_level, :link_tms_pattern, :link_issue_pattern, :clean_results_directory

    def initialize
      @results_directory = "reports/allure-results"
      @logging_level = LOGLEVELS.index(ENV.fetch("ALLURE_LOG_LEVEL", "INFO")) || Logger::INFO
    end

    # Allure id's of executable tests
    #
    # @return [Array]
    def test_ids
      @test_ids ||= tests&.map { |test| test[:id] }
    end

    # Test names of executable tests
    #
    # @return [Array]
    def test_names
      @test_names ||= tests&.map { |test| test[:selector] }
    end

    private

    # Tests to execute from allure testplan.json
    #
    # @return [Array<Hash>]
    def tests
      @tests ||= begin
        Oj.load_file("#{ENV[TESTPLAN_PATH]}/#{TESTPLAN_JSON}", symbol_keys: true)&.fetch(:tests) if ENV[TESTPLAN_PATH]
      end
    rescue Oj::ParseError
      nil
    end
  end
end
