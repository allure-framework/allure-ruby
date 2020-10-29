# frozen_string_literal: true

require "logger"
require "singleton"

module Allure
  # Allure configuration class
  class Config
    include Singleton

    # @return [Array<String>] valid log levels
    LOGLEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze
    # @return [String] test plan file name
    TEST_PLAN_JSON = "testplan.json"

    def initialize
      @results_directory = "reports/allure-results"
      @logging_level = LOGLEVELS.index(ENV.fetch("ALLURE_LOG_LEVEL", "INFO")) || Logger::INFO
    end

    attr_accessor :results_directory, :logging_level, :link_tms_pattern, :link_issue_pattern, :clean_results_directory

    # Tests to execute from allure testplan.json
    #
    # @return [Array<Hash>]
    def tests
      @tests ||= begin
        return unless ENV["ALLURE_TESTPLAN_PATH"]

        Oj.load_file("#{ENV['ALLURE_TESTPLAN_PATH']}/#{TEST_PLAN_JSON}", symbol_keys: true)&.fetch(:tests)
      end
    rescue Oj::ParseError
      nil
    end
  end
end
