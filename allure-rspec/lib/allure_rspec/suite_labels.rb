# frozen_string_literal: true

module AllureRspec
  # Suite label generator
  #
  class SuiteLabels
    include Utils

    def initialize(example_group)
      @example_group = example_group
    end

    # Get test suite labels
    # @return [Array<Allure::Label>]
    def fetch
      parents = example_group.parent_groups.map do |group|
        group.description.empty? ? "Anonymous" : group.description
      end

      labels = []
      labels << Allure::ResultUtils.suite_label(suite(parents))
      labels << Allure::ResultUtils.parent_suite_label(parent_suite(parents)) if parent_suite(parents)
      labels << Allure::ResultUtils.sub_suite_label(sub_suites(parents)) if sub_suites(parents)

      labels
    end

    private

    attr_reader :example_group

    # @param [Array<String>] parents
    # @return [String]
    def suite(parents)
      parents.length == 1 ? parents.last : parents[-2]
    end

    # @param [Array<String>] parents
    # @return [String]
    def parent_suite(parents)
      parents.length > 1 ? parents.last : nil
    end

    # @param [Array<String>] parents
    # @return [String]
    def sub_suites(parents)
      parents.length > 2 ? parents[0..-3].join(" > ") : nil
    end
  end
end
