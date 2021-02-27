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
    # @return [String] default epic tag prefix
    DEFAULT_EPIC_PREFIX = "EPIC:"
    # @return [String] default feature tag prefix
    DEFAULT_FEATURE_PREFIX = "FEATURE:"
    # @return [String] default story tag prefix
    DEFAULT_STORY_PREFIX = "STORY:"

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
      super()

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

    # @return [String]
    def epic_prefix
      @epic_prefix || DEFAULT_EPIC_PREFIX
    end

    # @return [String]
    def feature_prefix
      @feature_prefix || DEFAULT_FEATURE_PREFIX
    end

    # @return [String]
    def story_prefix
      @story_prefix || DEFAULT_STORY_PREFIX
    end
  end
end
