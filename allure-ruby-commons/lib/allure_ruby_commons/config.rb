# frozen_string_literal: true

require "logger"
require "singleton"

module Allure
  # Allure configuration class
  class Config
    include Singleton

    # @return [Array<String>] valid log levels
    LOGLEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze

    def initialize
      @results_directory = "reports/allure-results"
      @logging_level = LOGLEVELS.index(ENV.fetch("ALLURE_LOG_LEVEL", "INFO")) || Logger::INFO
    end

    attr_accessor :results_directory, :logging_level, :link_tms_pattern, :link_issue_pattern, :clean_results_directory
  end
end
