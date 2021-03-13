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
        severity,
        *behavior_labels,
        *tag_labels
      ].select(&:value)
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
      Allure::ResultUtils.severity_label(tag_value(:severity) || "normal")
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

    # Get behavior labels
    # @return [Array<Allure::Label>]
    def behavior_labels
      epic = tag_value(:epic) || scenario.feature_folder
      feature = tag_value(:feature) || scenario.feature_name
      story = tag_value(:story)

      [
        Allure::ResultUtils.epic_label(epic),
        Allure::ResultUtils.feature_label(feature),
        Allure::ResultUtils.story_label(story)
      ]
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

    # Get specific tag value
    #
    # @param [Symbol] type
    # @return [String]
    def tag_value(type)
      pattern = reserved_patterns[type]
      tag = tags.detect { |t| t.match?(pattern) }
      return unless tag

      tag.match(pattern)[type]
    end
  end
end
