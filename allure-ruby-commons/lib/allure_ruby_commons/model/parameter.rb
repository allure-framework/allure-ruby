# frozen_string_literal: true

module Allure
  # Allure model parameter object
  class Parameter < JSONable
    def initialize(name, value)
      super()

      @name = name
      @value = value
    end

    attr_reader :name, :value
  end
end
