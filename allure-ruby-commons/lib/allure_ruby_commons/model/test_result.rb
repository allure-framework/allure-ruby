# frozen_string_literal: true

module Allure
  # Allure model test result container
  class TestResult < ExecutableItem
    # @param [String] uuid
    # @param [String] history_id
    # @param [Hash] options
    # @option options [String] :name
    # @option options [String] :full_name
    # @option options [String] :description
    # @option options [String] :description_html
    # @option options [String] :status ('broken')
    # @option options [String] :stage ('scheduled')
    # @option options [Allure::StatusDetails] :status_details
    # @option options [Array<Allure::ExecutableItem>] :steps ([])
    # @option options [Array<Allure::Label>] :labels ([])
    # @option options [Array<Allure::Link>] :links ([])
    # @option options [Array<Allure::Attachment>] :attachments ([])
    # @option options [Array<Allure::Parameter>] :parameters ([])
    def initialize(uuid: UUID.generate, history_id: UUID.generate, **options)
      super
      @uuid = uuid
      @history_id = history_id
      @full_name = options[:full_name] || "Unnamed"
      @labels = options[:labels] || []
      @links = options[:links] || []
    end

    attr_accessor :uuid, :history_id, :full_name, :labels, :links
  end
end
