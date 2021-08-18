# frozen_string_literal: true

module AllureRspec
  # RSpec metadata parser
  #
  class RspecMetadataParser
    include Utils

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

    # Metadata parser instance
    #
    # @param [RSpec::Core::Example] example
    # @param [AllureRspec::RspecConfig] config <description>
    def initialize(example, config)
      @example = example
      @config = config
    end

    # Get allure labels
    # @return [Array<Allure::Label>]
    def labels
      [
        framework_label,
        package_label,
        test_class_label,
        severity,
        *tag_labels,
        *behavior_labels,
        *suite_labels
      ].select(&:value)
    end

    # Get attachable links
    # @return [Array<Allure::Link>]
    def links
      matching_links(:tms) + matching_links(:issue)
    end

    # Get status details
    # @return [Allure::StatusDetails]
    def status_details
      Allure::StatusDetails.new(
        flaky: !metadata[:flaky].nil?,
        muted: !metadata[:muted].nil?,
        known: !metadata[:known].nil?
      )
    end

    private

    # @return [RSpec::Core::Example]
    attr_reader :example

    # @return [AllureRspec::RspecConfig]
    attr_reader :config

    # Example metadata
    #
    # @return [Hash]
    def metadata
      @metadata ||= example.metadata
    end

    # Get package label
    # @return [Allure::Label]
    def package_label
      Allure::ResultUtils.package_label(Pathname.new(strip_relative(example.file_path)).parent.to_s)
    end

    # Get test class label
    #
    # @return [Allure::Label]
    def test_class_label
      Allure::ResultUtils.test_class_label(File.basename(example.file_path, ".rb"))
    end

    # Get framework label
    # @return [Allure::Label]
    def framework_label
      Allure::ResultUtils.framework_label("rspec")
    end

    # Get severity
    # @return [String]
    def severity
      Allure::ResultUtils.severity_label(metadata[config.severity_tag] || "normal")
    end

    # Get test suite labels
    # @return [Array<Allure::Label>]
    def suite_labels
      SuiteLabels.new(example.example_group).fetch
    end

    # Get custom labels
    # @return [Array<Allure::Label>]
    def tag_labels
      metadata
        .reject { |k| RSPEC_IGNORED_METADATA.include?(k) || special_metadata_tag?(k) }
        .map { |k, v| allure?(k) ? Allure::ResultUtils.tag_label(v) : Allure::ResultUtils.tag_label(k.to_s) }
    end

    # Get behavior labels
    # @return [Array<Allure::Label>]
    def behavior_labels
      metadata = example.metadata
      epic = metadata[config.epic_tag] || Pathname.new(strip_relative(example.file_path)).parent.to_s
      feature = metadata[config.feature_tag] || example.example_group.description
      story = metadata[config.story_tag]

      [
        Allure::ResultUtils.epic_label(epic),
        Allure::ResultUtils.feature_label(feature),
        Allure::ResultUtils.story_label(story)
      ]
    end

    # tms and issue links
    # @param [Symbol] type
    # @return [Array<Allure::Link>]
    def matching_links(type)
      link_pattern = config.public_send("link_#{type}_pattern")
      return [] unless link_pattern

      metadata
        .select { |key| __send__("#{type}?", key) }
        .map { |key, value| Allure::ResultUtils.public_send("#{type}_link", key.to_s, value, link_pattern) }
    end

    # Special allure metadata tags
    #
    # @param [Symbol] key
    # @return [boolean]
    def special_metadata_tag?(key)
      tms?(key) || issue?(key) || [
        config.severity_tag,
        config.epic_tag,
        config.feature_tag,
        config.story_tag,
        *config.ignored_tags
      ].include?(key)
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
      key.to_s.match?(/#{config.tms_tag}(_\d+)?/i)
    end

    # Does key match issue pattern
    # @param [Symbol] key
    # @return [boolean]
    def issue?(key)
      key.to_s.match?(/#{config.issue_tag}(_\d+)?/i)
    end
  end
end
