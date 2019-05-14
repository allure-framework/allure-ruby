# frozen_string_literal: true

require_relative "jsonable"

module Allure
  class Label < JSONable
    def initialize(name, value)
      @name = name
      @value = value
    end

    attr_accessor :name, :value
  end
end
