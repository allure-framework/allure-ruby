# frozen_string_literal: true

module AllureCucumber
  # Cucumber tag parser helper methods
  class MetadataParser
    def initialize(scenario)
      @scenario = scenario
    end

    # @return [Array<Allure::Label>]
    def labels
      [
        Allure::ResultUtils.framework_label("cucumber"),
        Allure::ResultUtils.package_label(scenario.feature_folder),
        Allure::ResultUtils.test_class_label(scenario.feature_file_name),
        Allure::ResultUtils.suite_label(scenario.feature_name),
        Allure::ResultUtils.feature_label(scenario.feature_name),
        Allure::ResultUtils.story_label(scenario.name),
        severity,
        *tag_labels
      ]
    end

    # @return [Array<Allure::Label>]
    def tag_labels
      tags
        .reject { |tag| reserved?(tag) }
        .map { |tag| Allure::ResultUtils.tag_label(tag.delete_prefix("@")) }
    end

    # @param [Cucumber::Core::Test::Case] test_case
    # @return [Array<Allure::Link>]
    def links
      tms_links + issue_links
    end

    # @return [Allure::Label]
    def severity
      severity_pattern = reserved_patterns[:severity]
      severity_tags = tags.detect { |tag| tag.match?(severity_pattern) }
      severity = severity_tags&.match(severity_pattern)&.[](:severity) || "normal"

      Allure::ResultUtils.severity_label(severity)
    end

    # @return [Array<Allure::Parameter>]
    def parameters
      scenario.examples.map { |k, v| Allure::Parameter.new(k, v) }
    end

    # @return [Hash<Symbol, Boolean>]
    def status_details
      Allure::StatusDetails.new(
        flaky: tags.any? { |tag| tag.match?(reserved_patterns[:flaky]) },
        muted: tags.any? { |tag| tag.match?(reserved_patterns[:muted]) },
        known: tags.any? { |tag| tag.match?(reserved_patterns[:known]) }
      )
    end

    private

    # @return [AllureCucumber::Scenario]
    attr_reader :scenario

    # Get scenario tags
    #
    # @return [Array<String>]
    def tags
      @tags ||= scenario.tags
    end

    # @return [Array<Allure::Link>]
    def tms_links
      return [] unless AllureCucumber.configuration.link_tms_pattern

      matching_links(:tms)
    end

    # @return [Array<Allure::Link>]
    def issue_links
      return [] unless AllureCucumber.configuration.link_issue_pattern

      matching_links(:issue)
    end

    # @param [Symbol] type
    # @return [Array<Allure::Link>]
    def matching_links(type)
      pattern = reserved_patterns[type]
      tags
        .select { |tag| tag.match?(pattern) }
        .map { |tag| tag.match(pattern) { |match| Allure::ResultUtils.public_send("#{type}_link", match[type]) } }
    end

    # @return [Hash<Symbol, Regexp>]
    def reserved_patterns
      @reserved_patterns ||= {
        tms: /@#{AllureCucumber.configuration.tms_prefix}(?<tms>\S+)/,
        issue: /@#{AllureCucumber.configuration.issue_prefix}(?<issue>\S+)/,
        severity: /@#{AllureCucumber.configuration.severity_prefix}(?<severity>\S+)/,
        epic: /@#{AllureCucumber.configuration.epic_prefix}(?<epic>\S+)/,
        feature: /@#{AllureCucumber.configuration.feature_prefix}(?<feature>\S+)/,
        story: /@#{AllureCucumber.configuration.story_prefix}(?<story>\S+)/,
        flaky: /@flaky/,
        muted: /@muted/,
        known: /@known/
      }
    end

    # @param [String] tag
    # @return [Boolean]
    def reserved?(tag)
      reserved_patterns.values.any? { |pattern| tag.match?(pattern) }
    end
  end
end
