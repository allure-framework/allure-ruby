# frozen_string_literal: true

module Allure
  # Main class for creating and writing allure results
  class AllureLifecycle
    def initialize
      @step_context = []
    end

    # Start test result container
    # @param [Allure::TestResultContainer] test_result_container
    # @return [Allure::TestResultContainer]
    def start_test_container(test_result_container)
      test_result_container.start = ResultUtils.timestamp
      @current_test_result_container = test_result_container
    end

    # @example Update current test container
    #   update_test_container do |container|
    #     container.stage = Allure::Stage::FINISHED
    #   end
    # @yieldparam [Allure::TestResultContainer] current test result container
    # @yieldreturn [void]
    # @return [void]
    def update_test_container
      unless @current_test_result_container
        return logger.error("Could not update test container, no container is running.")
      end

      yield(@current_test_result_container)
    end

    # Stop current test container and write result
    # @return [void]
    def stop_test_container
      unless @current_test_result_container
        return logger.error("Could not stop test container, no container is running.")
      end

      @current_test_result_container.stop = ResultUtils.timestamp
      file_writer.write_test_result_container(@current_test_result_container)
      clear_current_test_container
    end

    # Start test case and add to current test container
    # @param [Allure::TestResult] test_result
    # @return [Allure::TestResult]
    def start_test_case(test_result)
      clear_step_context
      unless @current_test_result_container
        return logger.error("Could not start test case, test container is not started")
      end

      test_result.start = ResultUtils.timestamp
      test_result.stage = Stage::RUNNING
      test_result.labels.push(ResultUtils.thread_label, ResultUtils.host_label, ResultUtils.language_label)
      @current_test_result_container.children.push(test_result.uuid)
      @current_test_case = test_result
    end

    # @example Update current test case
    #   update_test_container do |test_case|
    #     test_case.status = Allure::Status::FAILED
    #   end
    # @yieldparam [Allure::TestResult] current test
    # @yieldreturn [void]
    # @return [void]
    def update_test_case
      return logger.error("Could not update test case, no test case running") unless @current_test_case

      yield(@current_test_case)
    end

    # Stop current test case and write result
    # @return [void]
    def stop_test_case
      return logger.error("Could not stop test case, no test case is running") unless @current_test_case

      @current_test_case.stop = ResultUtils.timestamp
      @current_test_case.stage = Stage::FINISHED
      file_writer.write_test_result(@current_test_case)
      clear_current_test_case
      clear_step_context
    end

    # Start test step and add to current test case
    # @param [Allure::StepResult] step_result
    # @return [Allure::StepResult]
    def start_test_step(step_result)
      return logger.error("Could not start test step, no test case is running") unless @current_test_case

      step_result.start = ResultUtils.timestamp
      step_result.stage = Stage::RUNNING
      add_test_step(step_result)
      step_result
    end

    # @example Update current test step
    #   update_test_container do |test_step|
    #     test_step.status = Allure::Status::BROKEN
    #   end
    # @yieldparam [Allure::StepResult] current test step
    # @yieldreturn [void]
    # @return [void]
    def update_test_step
      return logger.error("Could not update test step, no step is running") unless current_test_step

      yield(current_test_step)
    end

    # Stop current test step
    # @return [void]
    def stop_test_step
      return logger.error("Could not stop test step, no step is running") unless current_test_step

      current_test_step.stop = ResultUtils.timestamp
      current_test_step.stage = Stage::FINISHED
      clear_last_test_step
    end

    # Start prepare fixture
    # @param [Allure::FixtureResult] fixture_result
    # @return [Allure::FixtureResult]
    def start_prepare_fixture(fixture_result)
      start_fixture(fixture_result) || return
      @current_test_result_container.befores.push(fixture_result)
      @current_fixture = fixture_result
    end

    # Start tear down fixture
    # @param [Allure::FixtureResult] fixture_result
    # @return [Allure::FixtureResult]
    def start_tear_down_fixture(fixture_result)
      start_fixture(fixture_result) || return
      @current_test_result_container.afters.push(fixture_result)
      @current_fixture = fixture_result
    end

    # Start fixture
    # @param [Allure::FixtureResult] fixture_result
    # @return [Allure::FixtureResult]
    def start_fixture(fixture_result)
      clear_step_context
      unless @current_test_result_container
        logger.error("Could not start fixture, test container is not started")
        return false
      end

      fixture_result.start = ResultUtils.timestamp
      fixture_result.stage = Stage::RUNNING
    end

    # @example Update current fixture
    #   update_test_container do |fixture|
    #     fixture.status = Allure::Status::BROKEN
    #   end
    # @yieldparam [Allure::FixtureResult] current fixture
    # @yieldreturn [void]
    # @return [void]
    def update_fixture
      return logger.error("Could not update fixture, fixture is not started") unless @current_fixture

      yield(@current_fixture)
    end

    def stop_fixture
      return logger.error("Could not stop fixture, fixture is not started") unless @current_fixture

      @current_fixture.stop = ResultUtils.timestamp
      @current_fixture.stage = Stage::FINISHED
      clear_current_fixture
      clear_step_context
    end

    # Add attachment to current test or step
    # @param [String] name Attachment name
    # @param [File, String] source File or string to save as attachment
    # @param [String] type attachment type defined in {Allure::ContentType} or any other valid mime type
    # @param [Boolean] test_case add attachment to current test case
    # @return [void]
    def add_attachment(name:, source:, type:, test_case: false)
      attachment = prepare_attachment(name, type) || begin
        return logger.error("Can't add attachment, unrecognized mime type: #{type}")
      end
      executable_item = (test_case && @current_test_case) || current_executable
      executable_item&.attachments&.push(attachment) || begin
        return logger.error("Can't add attachment, no test, step or fixture is running")
      end
      write_attachment(source, attachment)
    end

    # Create attachment object
    # @param [String] name
    # @param [String] type
    # @return [Allure::Attachment]
    def prepare_attachment(name, type)
      extension = ContentType.to_extension(type) || return
      file_name = "#{UUID.generate}-attachment.#{extension}"
      Attachment.new(name: name, source: file_name, type: type)
    end

    # Write attachment file
    # @param [File, String] source
    # @param [Allure::Attachment] attachment
    # @return [void]
    def write_attachment(source, attachment)
      file_writer.write_attachment(source, attachment)
    end

    # Add step to current fixture|step|test case
    # @param [Allure::StepResult] step_result
    # @return [Allure::StepResult]
    def add_test_step(step_result)
      current_executable.steps.push(step_result)
      @step_context.push(step_result)
      step_result
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT, level: Config.logging_level)
    end

    def file_writer
      @file_writer ||= FileWriter.new
    end

    def current_executable
      current_test_step || @current_fixture || @current_test_case
    end

    def clear_current_test_container
      @current_test_result_container = nil
    end

    def clear_current_test_case
      @current_test_case = nil
    end

    def current_test_step
      @step_context.last
    end

    def clear_last_test_step
      @step_context.pop
    end

    def clear_step_context
      @step_context.clear
    end

    def clear_current_fixture
      @current_fixture = nil
    end
  end
end
