# rubocop:disable Naming/FileName
# frozen_string_literal: true

require "allure-ruby-commons"

require "allure_cucumber/formatter"
require "allure_cucumber/config"

module Allure
  class << self
    # Get allure cucumber configuration
    # @return [Allure::CucumberConfig]
    def configuration
      CucumberConfig
    end

    # Set allure configuration
    # @yieldparam [Allure::CucumberConfig]
    # @yieldreturn [void]
    # @return [void]
    def configure
      yield(CucumberConfig)
    end
  end
end
# rubocop:enable Naming/FileName
