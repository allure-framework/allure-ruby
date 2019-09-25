# frozen_string_literal: true

module AllureRspec
  # RSpec custom tag parser
  module TagParser
    # @param [Hash] metadata
    # @return [String]
    def tms_link(metadata)
      return unless Allure::Config.link_tms_pattern && metadata.key?(:tms)

      Allure::ResultUtils.tms_link(metadata[:tms])
    end

    # @param [Hash] metadata
    # @return [String]
    def issue_link(metadata)
      return unless Allure::Config.link_issue_pattern && metadata.key?(:issue)

      Allure::ResultUtils.issue_link(metadata[:issue])
    end

    # @param [Hash] metadata
    # @return [String]
    def severity(metadata)
      Allure::ResultUtils.severity_label(metadata[:severity] || "normal")
    end

    # @param [Hash] metadata
    # @return [Hash<Symbol, Boolean>]
    def status_detail_tags(metadata)
      {
        flaky: !!metadata[:flaky],
        muted: !!metadata[:muted],
        known: !!metadata[:known],
      }
    end
  end
end
