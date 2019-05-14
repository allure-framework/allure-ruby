# frozen_string_literal: true

# Cucumber::Core::Ast is removed in cucumber-core 4.0 version.
# This will have to be updated accordingly, once stable version rolls out

module Allure
  module AstTransformer
    # Get scenario object
    # @param [Cucumber::Core::Test::Case] test_case
    # @return [Cucumber::Core::Ast::Scenario, Cucumber::Core::Ast::ScenarioOutline]
    def scenario(test_case)
      test_case.source.detect do |it|
        it.is_a?(Cucumber::Core::Ast::Scenario) || it.is_a?(Cucumber::Core::Ast::ScenarioOutline)
      end
    end

    # Get step object
    # @param [Cucumber::Core::Test::Step] test_case
    # @return [Cucumber::Core::Ast::Step]
    def step(test_step)
      test_step.source.detect { |it| it.is_a?(Cucumber::Core::Ast::Step) }
    end

    # Get scenario outline example row
    # @param [Cucumber::Core::Test::Case] test_case
    # @return [Cucumber::Core::Ast::ExamplesTable::Row]
    def example_row(test_case)
      test_case.source.detect { |it| it.is_a?(Cucumber::Core::Ast::ExamplesTable::Row) }
    end

    # Get step multiline argument
    # @param [Cucumber::Core::Test::Step] test_step
    # @return [Cucumber::Core::Ast::DataTable, String]
    def multiline_arg(test_step)
      multiline_arg = step(test_step).multiline_arg
      return if multiline_arg.is_a?(Cucumber::Core::Ast::EmptyMultilineArgument)

      multiline_arg
    end
  end
end
