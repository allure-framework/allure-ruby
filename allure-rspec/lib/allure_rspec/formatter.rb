# frozen_string_literal: true

require "ruby2_keywords"
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
      :example_group_started,
      :example_group_finished,
      :example_started,
      :example_finished
    )

    RSpec::Core::Example.class_eval do
      Allure.singleton_methods.each do |method|
        ruby2_keywords define_method(method) { |*args, &block| Allure.__send__(method, *args, &block) }
      end
    end

    RSpec.configure do |config|
      ids = Allure::TestPlan.test_ids
      names = Allure::TestPlan.test_names

      config.filter_run_when_matching(*ids.map { |id| { allure_id: id } }) if ids
      config.full_description = names if names
    end

    def initialize(output)
      super

      @lifecycle = (Allure.lifecycle = Allure::AllureLifecycle.new(AllureRspec.configuration))
      @config = @lifecycle.config
    end

    # Start test run
    # @param [RSpec::Core::Notifications::StartNotification] _start_notification
    # @return [void]
    def start(_start_notification)
      lifecycle.clean_results_dir
    end

    # Starts example group
    # @param [RSpec::Core::Notifications::GroupNotification] example_group_notification
    # @return [void]
    def example_group_started(example_group_notification)
      description = example_group_notification.group.description.yield_self do |desc|
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

    attr_reader :lifecycle, :config

    # Transform example to <Allure::TestResult>
    # @param [RSpec::Core::Example] example
    # @return [Allure::TestResult]
    def test_result(example)
      parser = RspecMetadataParser.new(example, config)

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

    # Get allure status from result
    # @param [RSpec::Core::Example::ExecutionResult] result
    # @return [Symbol]
    def status(result)
      return Allure::ResultUtils.status(result.exception) if result.status == :failed

      ALLURE_STATUS[result.status]
    end
  end
end
