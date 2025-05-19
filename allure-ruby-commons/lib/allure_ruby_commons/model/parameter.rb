# frozen_string_literal: true

module Allure
  # Allure model parameter object
  class Parameter < JSONable
    DEFAULT = "default".freeze
    MASKED = "masked".freeze
    HIDDEN = "hidden".freeze

    def initialize(name, value, excluded: false, mode: DEFAULT)
      super()

      @name = name
      @value = value
      @excluded = excluded
      @mode = validate_mode!(mode)
    end

    attr_reader :name, :value, :excluded, :mode

    private

    def validate_mode!(mode)
      modes = [DEFAULT, MASKED, HIDDEN]
      return mode if modes.include?(mode)

      Allure.configuration.logger.error "Parameter mode '#{mode}' is invalid. Valid modes are: #{modes.join(', ')}"
      DEFAULT
    end
  end
end
