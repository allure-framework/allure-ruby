# frozen_string_literal: true

require "rspec/core"
require "rspec/core/formatters/base_formatter"

require_relative "rspec_model"

module AllureRspec
  class RSpecFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register(
      self,
      :start,
      :example_group_started,
      :example_group_finished,
      :example_started,
      :example_finished,
    )

    def start(_start_notification)
      lifecycle.clean_results_dir
    end

    # Starts example group
    # @param [RSpec::Core::Notifications::GroupNotification] example_group
    # @return [void]
    def example_group_started(example_group_notification)
      lifecycle.start_test_container(
        Allure::TestResultContainer.new(name: example_group_notification.group.description),
      )
    end

    # Starts example
    # @param [RSpec::Core::Notifications::ExampleNotification] example
    # @return [void]
    def example_started(example_notification)
      lifecycle.start_test_case(AllureRspecModel.test_result(example_notification.example))
    end

    def example_finished(example_notification); end

    def example_group_finished(example_group_notification); end

    private

    # Get thread specific lifecycle
    # @return [Allure::AllureLifecycle]
    def lifecycle
      Allure.lifecycle
    end
  end
end
