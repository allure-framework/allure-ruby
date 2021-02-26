# frozen_string_literal: true

module AllureRspec
  # Suite label generator
  #
  class SuiteLabels
    include Utils

    def initialize(example_group)
      @example_group = example_group
    end

    # Get test suite labels
    # @return [Array<Allure::Label>]
    def fetch
      parents = example_group.parent_groups.map do |group|
        group.description.empty? ? "Anonymous" : group.description
      end

      labels = []
      labels << Allure::ResultUtils.suite_label(suite(parents))
      labels << Allure::ResultUtils.parent_suite_label(parent_suite(parents)) if parent_suite(parents)
      labels << Allure::ResultUtils.sub_suite_label(sub_suites(parents)) if sub_suites(parents)

      labels
    end

    private

    attr_reader :example_group

    # @param [Array<String>] parents
    # @return [String]
    def suite(parents)
      parents.length == 1 ? parents.last : parents[-2]
    end

    # @param [Array<String>] parents
    # @return [String]
    def parent_suite(parents)
      parents.length > 1 ? parents.last : nil
    end

    # @param [Array<String>] parents
    # @return [String]
    def sub_suites(parents)
      parents.length > 2 ? parents[0..-3].join(" > ") : nil
    end
  end

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

    def initialize(example)
      @example = example
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
      ]
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

    # @param [RSpec::Core::Example] example
    attr_reader :example

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
      Allure::ResultUtils.severity_label(metadata[:severity] || "normal")
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
      epic = metadata[:epic] || Pathname.new(strip_relative(example.file_path)).parent.to_s
      feature = metadata[:feature] || example.example_group.description
      story = metadata[:story] || example.description

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
      return [] unless AllureRspec.configuration.public_send("link_#{type}_pattern")

      metadata
        .select { |k| __send__("#{type}?", k) }.values
        .map { |v| Allure::ResultUtils.public_send("#{type}_link", v) }
    end

    # Special allure metadata tags
    #
    # @param [Symbol] key
    # @return [boolean]
    def special_metadata_tag?(key)
      tms?(key) || issue?(key) || %i[severity epic feature story].include?(key)
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
