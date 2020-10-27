# frozen_string_literal: true

module Allure
  # Allure model attachment object
  class Attachment < JSONable
    # @param [String] name attachment name
    # @param [String] type attachment type, {Allure::ContentType}
    # @param [String] source attachment file name
    def initialize(name:, type:, source:)
      super()

      @name = name
      @type = type
      @source = source
    end

    attr_accessor :name, :type, :source
  end
end
