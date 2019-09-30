# frozen_string_literal: true

require "digest"
require "pathname"

require_relative "tag_parser"

module AllureRspec
  module AllureRspecModel
    include TagParser

    # @return [Hash] allure statuses mapping
    ALLURE_STATUS ||= {
      failed: Allure::Status::FAILED,
      pending: Allure::Status::SKIPPED,
      passed: Allure::Status::PASSED,
    }.freeze

    # Transform example to <Allure::TestResult>
    # @param [RSpec::Core::Example] example
    # @return [Allure::TestResult]
    def test_result(example)
      Allure::TestResult.new(
        name: example.description,
        description: "Location - #{strip_relative(example.location)}",
        description_html: "Location - #{strip_relative(example.location)}",
        history_id: Digest::MD5.hexdigest(example.id),
        full_name: example.full_description,
        labels: labels(example),
        links: links(example),
        status_details: Allure::StatusDetails.new(**status_detail_tags(example.metadata)),
      )
    end

    # Update test status on finish
    # @param [RSpec::Core::Example::ExecutionResult] result
    # @return [Proc]
    def update_test_proc(result)
      Allure::ResultUtils.status_details(result.exception).yield_self do |status_detail|
        proc do |test_case|
          test_case.stage = Allure::Stage::FINISHED
          test_case.status = status(result)
          test_case.status_details.message = status_detail.message
          test_case.status_details.trace = status_detail.trace
        end
      end
    end

    private

    # @param [RSpec::Core::Example] example
    # @return [Array<Allure::Label>]
    def labels(example)
      [].tap do |labels|
        labels << Allure::ResultUtils.framework_label("rspec")
        labels << Allure::ResultUtils.feature_label(example.example_group.description)
        labels << Allure::ResultUtils.package_label(Pathname.new(strip_relative(example.file_path)).parent.to_s)
        labels << Allure::ResultUtils.story_label(example.description)
        labels << Allure::ResultUtils.test_class_label(File.basename(example.file_path, ".rb"))
        labels << severity(example.metadata)
        labels.push(*suite_labels(example.example_group))
        labels.push(*tag_labels(example.metadata))
      end
    end

    # Add suite labels
    # @param [RSpec::Core::ExampleGroup] example_group
    # @return [Array<Allure::Label>]
    def suite_labels(example_group)
      example_group.parent_groups.map(&:description).yield_self do |parents|
        [].tap do |labels|
          labels << Allure::ResultUtils.suite_label((parents.length == 1) ? parents.last : parents[-2])
          labels << Allure::ResultUtils.parent_suite_label(parents.last) if parents.length > 1
          labels << Allure::ResultUtils.sub_suite_label(parents[0..-3].join(" > ")) if parents.length > 2
        end
      end
    end

    # @param [RSpec::Core::Example] example
    # @return [Array<Allure::Label>]
    def links(example)
      tms_links(example.metadata) + issue_links(example.metadata)
    end

    # Get allure status from result
    # @param [RSpec::Core::Example::ExecutionResult] result
    # @return [Symbol]
    def status(result)
      return Allure::ResultUtils.status(result.exception) if result.status == :failed

      ALLURE_STATUS[result.status]
    end

    # Strip relative ./ form path
    # @param [String] path
    # @return [String]
    def strip_relative(path)
      path.gsub("./", "")
    end
  end
end
