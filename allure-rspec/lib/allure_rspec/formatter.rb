# frozen_string_literal: true

require "rspec/core"
require "rspec/core/formatters/base_formatter"

require_relative "rspec_model"

module AllureRspec
  class RSpecFormatter < RSpec::Core::Formatters::BaseFormatter
    include AllureRspecModel

    RSpec::Core::Formatters.register(
      self,
      :start,
      :example_group_started,
      :example_group_finished,
      :example_started,
      :example_finished,
    )

    RSpec::Core::Example.class_eval do
      Allure.singleton_methods.each do |method|
        define_method(method) { |*args, &block| Allure.__send__(method, *args, &block) }
      end
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
      lifecycle.start_test_container(
        Allure::TestResultContainer.new(name: example_group_notification.group.description),
      )
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
    # @param [RSpec::Core::Notifications::GroupNotification] example_group_notification
    # @return [void]
    def example_group_finished(_example_group_notification)
      lifecycle.stop_test_container
    end

    private

    # Get thread specific lifecycle
    # @return [Allure::AllureLifecycle]
    def lifecycle
      Allure.lifecycle
    end
  end
end
