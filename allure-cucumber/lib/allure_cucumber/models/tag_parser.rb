# frozen_string_literal: true

module AllureCucumber
  # Cucumber tag parser helper methods
  module TagParser
    # @param [Array<String>] tags
    # @return [Array<Allure::Label>]
    def tag_labels(tags)
      tags
        .reject { |tag| reserved?(tag) }
        .map { |tag| Allure::ResultUtils.tag_label(tag.delete_prefix("@")) }
    end

    # @param [Array<String>] tags
    # @return [Array<Allure::Link>]
    def tms_links(tags)
      return [] unless AllureCucumber.configuration.link_tms_pattern

      matching_links(tags, :tms)
    end

    # @param [Array<String>] tags
    # @return [Array<Allure::Link>]
    def issue_links(tags)
      return [] unless AllureCucumber.configuration.link_issue_pattern

      matching_links(tags, :issue)
    end

    # @param [Array<String>] tags
    # @return [Allure::Label]
    def severity(tags)
      severity_pattern = reserved_patterns[:severity]
      severity = tags
        .detect { |tag| tag.match?(severity_pattern) }
        &.match(severity_pattern)&.[](:severity) || "normal"

      Allure::ResultUtils.severity_label(severity)
    end

    # @param [Array<String>] tags
    # @return [Hash<Symbol, Boolean>]
    def status_detail_tags(tags)
      {
        flaky: tags.any? { |tag| tag.match?(reserved_patterns[:flaky]) },
        muted: tags.any? { |tag| tag.match?(reserved_patterns[:muted]) },
        known: tags.any? { |tag| tag.match?(reserved_patterns[:known]) },
      }
    end

    private

    # @param [Array<String>] tags
    # @param [Symbol] type
    # @return [Array<Allure::Link>]
    def matching_links(tags, type)
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
        flaky: /@flaky/,
        muted: /@muted/,
        known: /@known/,
      }
    end

    # @param [String] tag
    # @return [Boolean]
    def reserved?(tag)
      reserved_patterns.values.any? { |pattern| tag.match?(pattern) }
    end
  end
end
