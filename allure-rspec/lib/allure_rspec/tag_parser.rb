# frozen_string_literal: true

module AllureRspec
  # RSpec custom tag parser
  module TagParser
    # Get custom labels
    # @param [Hash] metadata
    # @return [Array<Allure::Label>]
    def tag_labels(metadata)
      return [] unless Allure::Config.link_tms_pattern && metadata.keys.any? { |k| allure?(k) }

      metadata.select { |k, _v| allure?(k) }.values.map { |v| Allure::ResultUtils.tag_label(v) }
    end

    # Get tms links
    # @param [Hash] metadata
    # @return [Array<Allure::Link>]
    def tms_links(metadata)
      return [] unless Allure::Config.link_tms_pattern && metadata.keys.any? { |k| tms?(k) }

      metadata.select { |k, _v| tms?(k) }.values.map { |v| Allure::ResultUtils.tms_link(v) }
    end

    # Get issue links
    # @param [Hash] metadata
    # @return [Array<Allure::Link>]
    def issue_links(metadata)
      return [] unless Allure::Config.link_issue_pattern && metadata.keys.any? { |k| issue?(k) }

      metadata.select { |k, _v| issue?(k) }.values.map { |v| Allure::ResultUtils.issue_link(v) }
    end

    # Get severity
    # @param [Hash] metadata
    # @return [String]
    def severity(metadata)
      Allure::ResultUtils.severity_label(metadata[:severity] || "normal")
    end

    # Get status details
    # @param [Hash] metadata
    # @return [Hash<Symbol, Boolean>]
    def status_detail_tags(metadata)
      {
        flaky: !!metadata[:flaky],
        muted: !!metadata[:muted],
        known: !!metadata[:known],
      }
    end

    private

    # Does key match custom allure label
    # @param [Symbol] key
    # @return [boolean]
    def allure?(key)
      key.to_s.match?(/allure(_\d+)?/i)
    end

    # Does key match tms pattern
    # @param [Symbol] key
    # @return [boolean]
    def tms?(key)
      key.to_s.match?(/tms(_\d+)?/i)
    end

    # Does key match issue pattern
    # @param [Symbol] key
    # @return [boolean]
    def issue?(key)
      key.to_s.match?(/issue(_\d+)?/i)
    end
  end
end
