# frozen_string_literal: true

require "singleton"

module AllureCucumber
  # Allure Cucumber configuration class
  #
  # @!attribute results_directory
  #   @return [String]
  # @!attribute clean_results_directory
  #   @return [Boolean]
  # @!attribute link_issue_pattern
  #   @return [String]
  # @!attribute link_tms_pattern
  #   @return [String]
  # @!attribute logging_level
  #   @return [Integer]
  # @!attribute [r] logger
  #   @return [Logger]
  # @!attribute environment
  #   @return [String]
  class CucumberConfig
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
                   :logger,
                   :logger=,
                   :results_directory,
                   :results_directory=,
                   :environment,
                   :environment=,
                   :environment_properties,
                   :environment_properties=,
                   :categories,
                   :categories=

    attr_writer :tms_prefix,
                :issue_prefix,
                :severity_prefix,
                :epic_prefix,
                :feature_prefix,
                :story_prefix

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
