# frozen_string_literal: true

module AllureRspec
  # RSpec custom tag parser
  module TagParser
    # Get custom labels
    # @param [Hash] metadata
    # @return [Array<Allure::Label>]
    def tag_labels(metadata)
      metadata.reject { |k| RSPEC_IGNORED_METADATA.include?(k) }.map do |k, v|
        allure?(k) ? Allure::ResultUtils.tag_label(v) : Allure::ResultUtils.tag_label(k.to_s)
      end
    end

    # Get tms links
    # @param [Hash] metadata
    # @return [Array<Allure::Link>]
    def tms_links(metadata)
      matching_links(metadata, :tms)
    end

    # Get issue links
    # @param [Hash] metadata
    # @return [Array<Allure::Link>]
    def issue_links(metadata)
      matching_links(metadata, :issue)
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
        flaky: !metadata[:flaky].nil?,
        muted: !metadata[:muted].nil?,
        known: !metadata[:known].nil?
      }
    end

    private

    RSPEC_IGNORED_METADATA = %i[
      absolute_file_path
      block
      described_class
      description
      description_args
      example_group
      execution_result
      file_path
      full_description
      last_run_status
      line_number
      location
      rerun_file_path
      retry
      retry_attempts
      retry_exceptions
      scoped_id
      shared_group_inclusion_backtrace
      type
    ].freeze

    # @param [Hash] metadata
    # @param [Symbol] type
    # @return [Array<Allure::Link>]
    def matching_links(metadata, type)
      unless AllureRspec.configuration.public_send("link_#{type}_pattern") &&
             metadata.keys.any? { |k| __send__("#{type}?", k) }
        return []
      end

      metadata
        .select { |k| __send__("#{type}?", k) }.values
        .map { |v| Allure::ResultUtils.public_send("#{type}_link", v) }
    end

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
