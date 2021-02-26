# frozen_string_literal: true

require "digest"
require "pathname"

module AllureRspec
  # Support class for transforming rspec test entities in to allure model entities
  module AllureRspecModel
    include AllureRspec::Utils

    # @return [Hash] allure statuses mapping
    ALLURE_STATUS = {
      failed: Allure::Status::FAILED,
      pending: Allure::Status::SKIPPED,
      passed: Allure::Status::PASSED
    }.freeze

    # Transform example to <Allure::TestResult>
    # @param [RSpec::Core::Example] example
    # @return [Allure::TestResult]
    def test_result(example)
      parser = RspecMetadataParser.new(example)

      Allure::TestResult.new(
        name: example.description,
        description: "Location - #{strip_relative(example.location)}",
        description_html: "Location - #{strip_relative(example.location)}",
        history_id: Digest::MD5.hexdigest(example.id),
        full_name: example.full_description,
        labels: parser.labels,
        links: parser.links,
        status_details: parser.status_details
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

    # Get allure status from result
    # @param [RSpec::Core::Example::ExecutionResult] result
    # @return [Symbol]
    def status(result)
      return Allure::ResultUtils.status(result.exception) if result.status == :failed

      ALLURE_STATUS[result.status]
    end
  end
end
