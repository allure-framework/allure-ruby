# frozen_string_literal: true

require "cucumber/core"

require_relative "models/cucumber_model"

module AllureCucumber
  # Main formatter class. Translates cucumber event to allure lifecycle
  class CucumberFormatter
    # @return [Hash] hook handler methods
    HOOK_HANDLERS = {
      "Before hook" => :start_prepare_fixture,
      "After hook" => :start_tear_down_fixture
    }.freeze
    # @return [Hash] allure statuses mapping
    ALLURE_STATUS = {
      failed: Allure::Status::FAILED,
      skipped: Allure::Status::SKIPPED,
      passed: Allure::Status::PASSED
    }.freeze

    # @param [Cucumber::Configuration] config
    def initialize(config)
      Allure.configure do |allure_config|
        allure_config.results_directory = config.out_stream if config.out_stream.is_a?(String)

        names = allure_config.test_names
        config.name_regexps.push(*names.map { |name| /#{name}/ }) if names
      end

      @cucumber_model = AllureCucumberModel.new(config)

      config.on_event(:test_run_started) { |event| on_test_run_started(event) }
      config.on_event(:test_case_started) { |event| on_test_case_started(event) }
      config.on_event(:test_step_started) { |event| on_test_step_started(event) }
      config.on_event(:test_step_finished) { |event| on_test_step_finished(event) }
      config.on_event(:test_case_finished) { |event| on_test_case_finished(event) }
    end

    # Clean test result directory before starting run
    # @param [Cucumber::Events::TestRunStarted] _event
    # @return [void]
    def on_test_run_started(_event)
      lifecycle.clean_results_dir
    end

    # Handle test case started event
    # @param [Cucumber::Events::TestCaseStarted] event
    # @return [void]
    def on_test_case_started(event)
      lifecycle.start_test_container(Allure::TestResultContainer.new(name: event.test_case.name))
      lifecycle.start_test_case(cucumber_model.test_result(event.test_case))
    end

    # Handle test step started event
    # @param [Cucumber::Events::TestStepStarted] event
    # @return [void]
    def on_test_step_started(event)
      event.test_step.hook? ? handle_hook_started(event.test_step) : handle_step_started(event.test_step)
    end

    # Handle test step finished event
    # @param [Cucumber::Events::TestStepFinished] event
    # @return [void]
    def on_test_step_finished(event)
      update_block = proc do |step|
        step.stage = Allure::Stage::FINISHED
        step.status = ALLURE_STATUS.fetch(event.result.to_sym, Allure::Status::BROKEN)
      end
      step_type = event.test_step.hook? ? "fixture" : "test_step"

      lifecycle.public_send("update_#{step_type}", &update_block)
      lifecycle.public_send("stop_#{step_type}")
    end

    # Handle test case finished event
    # @param [Cucumber::Events::TestCaseFinished] event
    # @return [void]
    def on_test_case_finished(event)
      failure_details = cucumber_model.failure_details(event.result)
      status = ALLURE_STATUS.fetch(event.result.to_sym, Allure::Status::BROKEN)
      lifecycle.update_test_case do |test_case|
        test_case.stage = Allure::Stage::FINISHED
        test_case.status = event.result.failed? ? Allure::ResultUtils.status(event.result&.exception) : status
        test_case.status_details.flaky = event.result.flaky?
        test_case.status_details.message = failure_details[:message]
        test_case.status_details.trace = failure_details[:trace]
      end
      lifecycle.stop_test_case
      lifecycle.stop_test_container
    end

    private

    attr_accessor :cucumber_model

    # Get thread specific lifecycle
    # @return [Allure::AllureLifecycle]
    def lifecycle
      Allure.lifecycle
    end

    # @param [Cucumber::Core::Test::Step] test_step
    # @return [void]
    def handle_step_started(test_step)
      step = cucumber_model.step_result(test_step)
      lifecycle.start_test_step(step[:allure_step])
      step[:attachments].each { |att| lifecycle.write_attachment(att[:source], att[:allure_attachment]) }
    end

    # @param [Cucumber::Core::Test::HookStep] hook_step
    # @return [void]
    def handle_hook_started(hook_step)
      return unless HOOK_HANDLERS.key?(hook_step.text)

      lifecycle.public_send(HOOK_HANDLERS[hook_step.text], cucumber_model.fixture_result(hook_step))
    end
  end
end
