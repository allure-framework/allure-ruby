# frozen_string_literal: true

require "rspec/core"
require "rspec/core/formatters/base_formatter"

# Main allure-rspec module
module AllureRspec
  # Main rspec formatter class translating rspec events to allure lifecycle
  class RSpecFormatter < RSpec::Core::Formatters::BaseFormatter
    include Utils

    # @return [Hash] allure statuses mapping
    ALLURE_STATUS = {
      failed: Allure::Status::FAILED,
      pending: Allure::Status::SKIPPED,
      passed: Allure::Status::PASSED
    }.freeze

    RSpec::Core::Formatters.register(
      self,
      :start,
      :stop,
      :example_group_started,
      :example_group_finished,
      :example_started,
      :example_finished
    )

    RSpec.configure do |config|
      ids = Allure::TestPlan.test_ids
      names = Allure::TestPlan.test_names

      config.filter_run_when_matching(*ids.map { |id| { allure_id: id } }) if ids
      config.full_description = names if names
    end

    def initialize(output)
      super

      @allure_config = AllureRspec.configuration
      Allure.lifecycle = @lifecycle = Allure::AllureLifecycle.new(@allure_config)
    end

    # Start test run
    # @param [RSpec::Core::Notifications::StartNotification] _start_notification
    # @return [void]
    def start(_start_notification)
      lifecycle.clean_results_dir
      lifecycle.write_categories

      RSpec::Core::Example.class_eval do
        include Allure
      end
    end

    # Start test run
    # @param [RSpec::Core::Notifications::StopNotification] _stop_notification
    # @return [void]
    def stop(_stop_notification)
      lifecycle.write_environment
    end

    # Starts example group
    # @param [RSpec::Core::Notifications::GroupNotification] example_group_notification
    # @return [void]
    def example_group_started(example_group_notification)
      description = example_group_notification.group.description.then do |desc|
        desc.empty? ? "Anonymous" : desc
      end
      lifecycle.start_test_container(Allure::TestResultContainer.new(name: description))
    end

    # Starts example
    # @param [RSpec::Core::Notifications::ExampleNotification] example_notification
    # @return [void]
    def example_started(example_notification)
      lifecycle.start_test_case(test_result(example_notification.example))
    end

    # Finishes example
    # @param [RSpec::Core::Notifications::ExampleNotification] example_notification
    # @return [void]
    def example_finished(example_notification)
      lifecycle.update_test_case(&update_test_proc(example_notification.example.execution_result))
      lifecycle.stop_test_case
    end

    # Starts example group
    # @param [RSpec::Core::Notifications::GroupNotification] _example_group_notification
    # @return [void]
    def example_group_finished(_example_group_notification)
      lifecycle.stop_test_container
    end

    private

    attr_reader :lifecycle, :allure_config

    # Transform example to <Allure::TestResult>
    # @param [RSpec::Core::Example] example
    # @return [Allure::TestResult]
    def test_result(example)
      parser = RspecMetadataParser.new(example, allure_config)

      Allure::TestResult.new(
        name: example.description,
        description: "Location - #{strip_relative(example.location)}",
        description_html: "Location - #{strip_relative(example.location)}",
        history_id: example.id,
        full_name: example.full_description,
        labels: parser.labels,
        links: parser.links,
        status_details: parser.status_details,
        environment: allure_config.environment
      )
    end

    # Update test status on finish
    # @param [RSpec::Core::Example::ExecutionResult] result
    # @return [Proc]
    def update_test_proc(result)
      Allure::ResultUtils.status_details(result.exception).then do |status_detail|
        proc do |test_case|
          test_case.stage = Allure::Stage::FINISHED
          test_case.status = status(result)
          test_case.status_details.message = status_detail.message
          test_case.status_details.trace = status_detail.trace
        end
      end
    end

    # Get allure status from result
    # @param [RSpec::Core::Example::ExecutionResult] result
    # @return [Symbol]
    def status(result)
      return Allure::ResultUtils.status(result.exception) if result.status == :failed

      ALLURE_STATUS[result.status]
    end
  end
end
