# rubocop:disable Naming/FileName
# frozen_string_literal: true

require "allure-ruby-commons"

require_rel "allure_cucumber"

# Main allure-cucumber module providing configuration methods
module AllureCucumber
  class << self
    # Get allure cucumber configuration
    # @return [Allure::CucumberConfig]
    def configuration
      CucumberConfig.instance
    end

    # Set allure configuration
    # @yieldparam [Allure::CucumberConfig]
    # @yieldreturn [void]
    # @return [void]
    def configure
      yield(configuration)
    end
  end
end
# rubocop:enable Naming/FileName
