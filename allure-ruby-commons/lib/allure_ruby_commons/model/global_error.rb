# frozen_string_literal: true

require_relative "status_details"

module Allure
  # Allure model global error object
  class GlobalError < StatusDetails
    # @param [Number] timestamp
    # @param [Hash] options
    # @option options [Boolean] :known
    # @option options [Boolean] :muted
    # @option options [Boolean] :flaky
    # @option options [String] :message
    # @option options [String] :trace
    def initialize(timestamp:, **options)
      super(**options)

      @timestamp = timestamp
    end

    attr_accessor :timestamp
  end
end
