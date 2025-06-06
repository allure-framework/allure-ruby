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
    def initialize(uuid: SecureRandom.uuid, history_id: SecureRandom.uuid, environment: nil, **options)
      super

      @name = options[:name]
      @uuid = uuid
      @history_id = history_id
      @full_name = options[:full_name] || "Unnamed"
      @labels = options[:labels] || []
      @links = options[:links] || []
      @parameters << Parameter.new("environment", environment) if environment
    end

    attr_accessor :uuid,
                  :full_name,
                  :labels,
                  :links

    attr_writer :history_id

    # History id
    #
    # @return [String]
    def history_id
      Digest::MD5.hexdigest("#{@history_id}#{parameters_string}")
    end

    private

    # All parameters string
    #
    # @return [String]
    def parameters_string
      parameters.reject(&:excluded).map { |p| "#{p.name}=#{p.value}" }.join(";")
    end
  end
end
