# frozen_string_literal: true

module Allure
  class StatusDetails < JSONable
    # @param [Boolean] known
    # @param [Boolean] muted
    # @param [Boolean] flaky
    # @param [String] message
    # @param [String] trace
    def initialize(known: false, muted: false, flaky: false, message: nil, trace: nil)
      @known = known
      @muted = muted
      @flaky = flaky
      @message = message
      @trace = trace
    end

    attr_accessor :known, :muted, :flaky, :message, :trace
  end
end
