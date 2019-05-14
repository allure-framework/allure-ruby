# frozen_string_literal: true

require_relative "jsonable"

module Allure
  class Parameter < JSONable
    def initialize(name, value)
      @name = name
      @value = value
    end

    attr_reader :name, :value
  end
end
