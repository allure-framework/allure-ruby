# frozen_string_literal: true

module Allure
  # Allure model label object
  class Label < JSONable
    def initialize(name, value)
      super()

      @name = name
      @value = value
    end

    attr_accessor :name, :value
  end
end
