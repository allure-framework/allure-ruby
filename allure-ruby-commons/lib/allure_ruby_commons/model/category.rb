# frozen_string_literal: true

module Allure
  # Defects category
  class Category < JSONable
    # @param [String] name
    # @param [Array<Allure::Status>] matched_statuses
    # @param [String, Regexp] message_regex
    # @param [String, Regexp] trace_regex
    def initialize(name:, matched_statuses: nil, message_regex: nil, trace_regex: nil)
      super()

      @name = name
      @matched_statuses = matched_statuses
      @message_regex = message_regex
      @trace_regex = trace_regex
    end
  end
end
