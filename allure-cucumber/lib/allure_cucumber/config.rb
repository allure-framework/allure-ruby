# frozen_string_literal: true

require "singleton"
require "forwardable"

module AllureCucumber
  # Allure cucumber configuration
  class CucumberConfig < Allure::Config
    include Singleton
    extend Forwardable

    # @return [String] default tms tag prefix
    DEFAULT_TMS_PREFIX = "TMS:"
    # @return [String] default issue tag prefix
    DEFAULT_ISSUE_PREFIX = "ISSUE:"
    # @return [String] default severity tag prefix
    DEFAULT_SEVERITY_PREFIX = "SEVERITY:"

    def_delegators :@allure_config,
      :clean_results_directory,
      :clean_results_directory=,
      :link_issue_pattern,
      :link_issue_pattern=,
      :link_tms_pattern,
      :link_tms_pattern=,
      :logging_level,
      :logging_level=,
      :results_directory,
      :results_directory=

    attr_writer :tms_prefix, :issue_prefix, :severity_prefix

    def initialize
      @allure_config = Allure.configuration
    end

    # @return [String]
    def tms_prefix
      @tms_prefix || DEFAULT_TMS_PREFIX
    end

    # @return [String]
    def issue_prefix
      @issue_prefix || DEFAULT_ISSUE_PREFIX
    end

    # @return [String]
    def severity_prefix
      @severity_prefix || DEFAULT_SEVERITY_PREFIX
    end
  end
end
