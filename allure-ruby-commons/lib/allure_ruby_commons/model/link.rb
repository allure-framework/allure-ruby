# frozen_string_literal: true

require_relative "jsonable"

module Allure
  class Link < JSONable
    def initialize(type, name, url)
      @type = type
      @name = name
      @url = url
    end

    attr_accessor :type, :name, :url
  end
end
