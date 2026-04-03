# frozen_string_literal: true

module Allure
  # Allure model global attachment object
  class GlobalAttachment < Attachment
    # @param [Number] timestamp
    # @param [Hash] options
    # @option options [String] :name attachment name
    # @option options [String] :type attachment type, {Allure::ContentType}
    # @option options [String] :source attachment file name
    def initialize(timestamp:, **options)
      super(**options)

      @timestamp = timestamp
    end

    attr_accessor :timestamp
  end
end
