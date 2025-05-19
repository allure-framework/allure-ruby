# frozen_string_literal: true

module Allure
  # Allure model parameter object
  class Parameter < JSONable
    MODES = %w[default masked hidden].freeze
    def initialize(name, value, excluded: false, mode: "default")
      super()

      @name = name
      @value = value
      @excluded = excluded
      validate_mode!(mode)
      @mode = mode
    end

    attr_reader :name, :value, :excluded, :mode

    private

    def validate_mode!(mode)
      return if MODES.include?(mode)

      Allure.configuration.logger.error "Parameter mode '#{mode}' is invalid. Valid modes are: #{MODES.join(', ')}"
    end
  end
end
