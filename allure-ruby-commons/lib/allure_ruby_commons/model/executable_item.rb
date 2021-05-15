# frozen_string_literal: true

module Allure
  # Allure model executable item
  class ExecutableItem < JSONable
    # @param [Hash] options
    # @option options [String] :name
    # @option options [String] :description
    # @option options [String] :description_html
    # @option options [String] :stage ('scheduled'), {Allure::Stage}
    # @option options [String] :status ('broken'), {Allure::Status}
    # @option options [Allure::StatusDetails] :status_details
    # @option options [Array<Allure::ExecutableItem>] :steps ([])
    # @option options [Array<Allure::Attachment>] :attachments ([])
    # @option options [Array<Allure::Parameter>] :parameters ([])
    def initialize(**options)
      super()

      @name = options[:name]
      @description = options[:description]
      @description_html = options[:description_html]
      @status = options[:status] || Status::BROKEN
      @status_details = options[:status_details] || StatusDetails.new
      @stage = options[:stage] || Stage::SCHEDULED
      @steps = options[:steps] || []
      @attachments = options[:attachments] || []
      @parameters = options[:parameters] || []
    end

    attr_accessor :name,
                  :status,
                  :status_details,
                  :stage,
                  :description,
                  :description_html,
                  :steps,
                  :attachments,
                  :parameters,
                  :start,
                  :stop
  end
end
