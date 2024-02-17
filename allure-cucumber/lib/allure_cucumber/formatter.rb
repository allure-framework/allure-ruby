# frozen_string_literal: true

require "cucumber/core"

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
      allure_config = AllureCucumber.configuration
      allure_config.results_directory = config.out_stream if config.out_stream.is_a?(String)

      Allure.lifecycle = @lifecycle = Allure::AllureLifecycle.new(allure_config)

      @cucumber_model ||= AllureCucumberModel.new(config, allure_config)

      names = Allure::TestPlan.test_names
      config.name_regexps.push(*names.map { |name| /#{name}/ }) if names

      config.on_event(:test_run_started) { |event| on_test_run_started(event) }
      config.on_event(:test_run_finished) { |event| on_test_run_finished(event) }
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
      lifecycle.write_categories
    end

    # Clean test result directory before starting run
    # @param [Cucumber::Events::TestRunFinished] _event
    # @return [void]
    def on_test_run_finished(_event)
      lifecycle.write_environment
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
      status = ALLURE_STATUS.fetch(event.result.to_sym, Allure::Status::BROKEN)
      update_block = proc do |step|
        step.stage = Allure::Stage::FINISHED
        step.status = event.result.failed? ? Allure::ResultUtils.status(event.result&.exception) : status
      end

      event.test_step.hook? ? handle_hook_finished(event.test_step, update_block) : handle_step_finished(update_block)
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

    attr_reader :lifecycle, :cucumber_model

    # Is hook fixture like Before, After or Step as AfterStep
    # @param [String] text
    # @return [boolean]
    def fixture_hook?(text)
      HOOK_HANDLERS.key?(text)
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
      result = cucumber_model.fixture_result(hook_step)
      return lifecycle.start_test_step(result) unless fixture_hook?(hook_step.text)

      lifecycle.public_send(HOOK_HANDLERS[hook_step.text], result)
    end

    # @param [Proc] update_block
    # @return [void]
    def handle_step_finished(update_block)
      lifecycle.update_test_step(&update_block)
      lifecycle.stop_test_step
    end

    # @param [Cucumber::Core::Test::HookStep] hook_step
    # @param [Proc] update_block
    # @return [void]
    def handle_hook_finished(hook_step, update_block)
      return handle_step_finished(update_block) unless fixture_hook?(hook_step.text)

      lifecycle.update_fixture(&update_block)
      lifecycle.stop_fixture
    end
  end
end
