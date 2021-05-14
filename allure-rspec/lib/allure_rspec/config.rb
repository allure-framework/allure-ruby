# frozen_string_literal: true

require "singleton"

module AllureRspec
  # Shorthand configuration class
  class RspecConfig < Allure::Config
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
                   :results_directory,
                   :results_directory=

    def initialize
      super()

      @allure_config = Allure.configuration
    end
  end
end
