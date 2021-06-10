# frozen_string_literal: true

module Allure
  # Allure model test result container
  class TestResult < ExecutableItem
    # @param [String] uuid
    # @param [String] history_id
    # @param [String] environment
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
    def initialize(uuid: UUID.generate, history_id: UUID.generate, environment: nil, **options)
      super

      @name = options[:name]
      @uuid = uuid
      @history_id = Digest::MD5.hexdigest("#{history_id}#{environment}")
      @full_name = options[:full_name] || "Unnamed"
      @labels = options[:labels] || []
      @links = options[:links] || []
      @parameters = updated_parameters(options[:parameters] || [], environment)
    end

    attr_accessor :uuid,
                  :history_id,
                  :full_name,
                  :labels,
                  :links,
                  :parameters

    private

    # Test name prefixed with allure environment
    #
    # @param [Array] parameters
    # @param [String] environment
    # @return [Array]
    def updated_parameters(parameters, environment)
      return parameters unless environment

      parameters << Parameter.new("environment", environment)
    end
  end
end
