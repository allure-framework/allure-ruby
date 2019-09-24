# frozen_string_literal: true

require "rspec/core"
require "rspec/core/formatters/base_formatter"

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

    def example_group_started(example_group); end

    def example_started(example); end

    def example_finished(example); end

    def example_group_finished(example_group); end

    private

    # Get thread specific lifecycle
    # @return [Allure::AllureLifecycle]
    def lifecycle
      Allure.lifecycle
    end
  end
end
