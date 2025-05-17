# frozen_string_literal: true

module Allure
  # Allure model parameter object
  class Parameter < JSONable
    def initialize(name, value, excluded: false, mode: 'default')
      super()

      @name = name
      @value = value
      @excluded = excluded
      @mode = mode
    end

    attr_reader :name, :value, :excluded, :mode
  end
end
