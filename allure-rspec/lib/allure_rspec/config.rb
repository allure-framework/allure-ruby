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
                   :results_directory,
                   :results_directory=,
                   :environment,
                   :environment=

    def initialize
      @allure_config = Allure.configuration
    end
  end
end
