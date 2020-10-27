# frozen_string_literal: true

module Allure
  # Allure model link object
  class Link < JSONable
    def initialize(type, name, url)
      super()

      @type = type
      @name = name
      @url = url
    end

    attr_accessor :type, :name, :url
  end
end
