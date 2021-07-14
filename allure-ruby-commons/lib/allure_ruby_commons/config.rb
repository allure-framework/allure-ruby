# frozen_string_literal: true

require "logger"
require "singleton"

module Allure
  # Allure configuration class
  class Config
    include Singleton

    # @return [Array<String>] valid log levels
    LOGLEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze

    attr_writer :environment, :logger

    attr_accessor :results_directory,
                  :logging_level,
                  :link_tms_pattern,
                  :link_issue_pattern,
                  :clean_results_directory,
                  :environment_properties,
                  :categories

    def initialize
      @results_directory = "reports/allure-results"
      @logging_level = LOGLEVELS.index(ENV.fetch("ALLURE_LOG_LEVEL", "INFO")) || Logger::INFO
    end

    # Allure environment
    #
    # @return [String]
    def environment
      return(@environment) if defined?(@environment)

      @environment ||= ENV["ALLURE_ENVIRONMENT"]
    end

    # Logger instance
    #
    # @return [Logger]
    def logger
      @logger ||= Logger.new($stdout, level: logging_level)
    end
  end
end
