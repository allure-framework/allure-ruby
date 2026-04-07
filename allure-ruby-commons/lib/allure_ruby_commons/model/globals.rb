# frozen_string_literal: true

module Allure
  # Allure model run-level globals chunk
  class Globals < JSONable
    # @param [Array<Allure::GlobalAttachment>] attachments
    # @param [Array<Allure::GlobalError>] errors
    def initialize(attachments: [], errors: [])
      super()

      @attachments = attachments
      @errors = errors
    end

    attr_accessor :attachments, :errors
  end
end
