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

    # Add an error to the globals
    # @param [Allure::GlobalError] error
    # @return [void]
    def add_error(error)
      @errors.push(error)
    end

    # Add an attachment to the globals
    # @param [Allure::GlobalAttachment] attachment
    # @return [void]
    def add_attachment(attachment)
      @attachments.push(attachment)
    end
  end
end
