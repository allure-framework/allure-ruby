# frozen_string_literal: true

require_relative "jsonable"

module Allure
  # Allure model attachment object
  class Attachment < JSONable
    # @param [String] name attachment name
    # @param [String] type attachment type, {Allure::ContentType}
    # @param [String] source attachment file name
    def initialize(name:, type:, source:)
      @name = name
      @type = type
      @source = source
    end

    # Create unique attachment object
    # @param [String] name
    # @param [String] type
    # @return [Allure::Attachment]
    def self.prepare_attachment(name, type)
      extension = ContentType.to_extension(type) || return
      file_name = "#{UUID.generate}-attachment.#{extension}"
      new(name: name, source: file_name, type: type)
    end

    attr_accessor :name, :type, :source
  end
end
