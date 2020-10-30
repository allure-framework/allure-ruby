# frozen_string_literal: true

require "ruby2_keywords"
require "rspec/core"
require "rspec/core/formatters/base_formatter"

require_relative "rspec_model"

# Main allure-rspec module
module AllureRspec
  # Main rspec formatter class translating rspec events to allure lifecycle
  class RSpecFormatter < RSpec::Core::Formatters::BaseFormatter
    include AllureRspecModel

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
      ids = AllureRspec.configuration.test_ids
      names = AllureRspec.configuration.test_names

      config.filter_run_when_matching(*ids.map { |id| { allure_id: id } }) if ids
      config.prepend_before { |ex| ex.skip("Skip set by allure") if names.include?(ex.full_description) } if name
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

    # Get thread specific lifecycle
    # @return [Allure::AllureLifecycle]
    def lifecycle
      Allure.lifecycle
    end
  end
end
