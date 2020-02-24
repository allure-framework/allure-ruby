# frozen_string_literal: true

require_relative "config"

module AllureCucumber
  # Cucumber tag parser helper methods
  module TagParser
    # @param [Array<Cucumber::Core::Ast::Tag>] tags
    # @return [Array<Allure::Label>]
    def tag_labels(tags)
      tags
        .reject { |tag| reserved?(tag.name) }
        .map { |tag| Allure::ResultUtils.tag_label(tag.name.delete_prefix("@")) }
    end

    # @param [Array<Cucumber::Core::Ast::Tag>] tags
    # @return [Array<Allure::Link>]
    def tms_links(tags)
      return [] unless Allure::Config.link_tms_pattern

      matching_links(tags, :tms)
    end

    # @param [Array<Cucumber::Core::Ast::Tag>] tags
    # @return [Array<Allure::Link>]
    def issue_links(tags)
      return [] unless Allure::Config.link_issue_pattern

      matching_links(tags, :issue)
    end

    # @param [Array<Cucumber::Core::Ast::Tag>] tags
    # @return [Allure::Label]
    def severity(tags)
      severity_pattern = reserved_patterns[:severity]
      severity = tags
        .detect { |tag| tag.name.match?(severity_pattern) }&.name
        &.match(severity_pattern)&.[](:severity) || "normal"

      Allure::ResultUtils.severity_label(severity)
    end

    # @param [Array<Cucumber::Core::Ast::Tag>] tags
    # @return [Hash<Symbol, Boolean>]
    def status_detail_tags(tags)
      {
        flaky: tags.any? { |tag| tag.match?(reserved_patterns[:flaky]) },
        muted: tags.any? { |tag| tag.match?(reserved_patterns[:muted]) },
        known: tags.any? { |tag| tag.match?(reserved_patterns[:known]) },
      }
    end

    private

    # @param [Array<Cucumber::Core::Ast::Tag>] tags
    # @param [Symbol] type
    # @return [Array<Allure::Link>]
    def matching_links(tags, type)
      pattern = reserved_patterns[type]
      tags
        .select { |tag| tag.name.match?(pattern) }
        .map { |tag| tag.name.match(pattern) { |match| Allure::ResultUtils.public_send("#{type}_link", match[type]) } }
    end

    # @return [Hash<Symbol, Regexp>]
    def reserved_patterns
      @reserved_patterns ||= {
        tms: /@#{CucumberConfig.tms_prefix}(?<tms>\S+)/,
        issue: /@#{CucumberConfig.issue_prefix}(?<issue>\S+)/,
        severity: /@#{CucumberConfig.severity_prefix}(?<severity>\S+)/,
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
