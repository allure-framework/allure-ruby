# frozen_string_literal: true

require "singleton"

module AllureRspec
  # Allure RSpec configuration class
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
  class RspecConfig
    include Singleton
    extend Forwardable

    # @return [Symbol] default tms tag
    DEFAULT_TMS_TAG = :tms
    # @return [Symbol] default issue tag
    DEFAULT_ISSUE_TAG = :issue
    # @return [Symbol] default severity tag
    DEFAULT_SEVERITY_TAG = :severity
    # @return [Symbol] default epic tag
    DEFAULT_EPIC_TAG = :epic
    # @return [Symbol] default feature tag
    DEFAULT_FEATURE_TAG = :feature
    # @return [Symbol] default story tag
    DEFAULT_STORY_TAG = :story

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

    def initialize
      @allure_config = Allure.configuration
    end

    attr_writer :tms_tag,
                :issue_tag,
                :severity_tag,
                :epic_tag,
                :feature_tag,
                :story_tag,
                :ignored_tags

    # @return [Symbol]
    def tms_tag
      @tms_tag || DEFAULT_TMS_TAG
    end

    # @return [Symbol]
    def issue_tag
      @issue_tag || DEFAULT_ISSUE_TAG
    end

    # @return [Symbol]
    def severity_tag
      @severity_tag || DEFAULT_SEVERITY_TAG
    end

    # @return [Symbol]
    def epic_tag
      @epic_tag || DEFAULT_EPIC_TAG
    end

    # @return [Symbol]
    def feature_tag
      @feature_tag || DEFAULT_FEATURE_TAG
    end

    # @return [Symbol]
    def story_tag
      @story_tag || DEFAULT_STORY_TAG
    end

    # @return [Array]
    def ignored_tags
      @ignored_tags || []
    end
  end
end
