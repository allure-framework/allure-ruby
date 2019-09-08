# frozen_string_literal: true

require "logger"

module Allure
  # Allure configuration class
  class Config
    # @return [String] default allure results directory
    DEFAULT_RESULTS_DIRECTORY = "reports/allure-results"
    # @return [String] default loggin level
    DEFAULT_LOGGING_LEVEL = Logger::INFO

    class << self
      attr_accessor :link_tms_pattern, :link_issue_pattern
      attr_writer :results_directory, :logging_level

      def results_directory
        @results_directory || DEFAULT_RESULTS_DIRECTORY
      end

      def logging_level
        @logging_level || DEFAULT_LOGGING_LEVEL
      end
    end
  end
end
