# frozen_string_literal: true

require "cucumber/core/filter"

module AllureCucumber
  # Select test-plan cases before hooks and execution are applied.
  class TestPlanFilter < Cucumber::Core::Filter.new(:model, :selectors)
    # @param [Cucumber::Core::Test::Case] test_case
    # @return [TestPlanFilter]
    def test_case(test_case)
      test_case.describe_to(receiver) if model.selected?(test_case, selectors)
      self
    end
  end
end
