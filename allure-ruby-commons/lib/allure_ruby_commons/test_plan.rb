# frozen_string_literal: true

require "set"

module Allure
  class TestPlan
    extend JsonHelper

    # @return [String] test plan path env var name
    TESTPLAN_PATH = "ALLURE_TESTPLAN_PATH"

    class << self
      # Allure id's of executable tests
      #
      # @return [Array]
      def test_ids
        @test_ids ||= tests&.filter_map { |test| test[:id] }
      end

      # Test names of executable tests
      #
      # @return [Array]
      def test_names
        @test_names ||= tests&.filter_map { |test| test[:selector] }
      end

      # Whether a test case identity is muted
      #
      # @param [String] test_case_id
      # @return [Boolean]
      def muted?(test_case_id)
        muted_test_ids.include?(test_case_id)
      end

      # Whether the test plan contains any muted identities
      #
      # @return [Boolean]
      def muted_tests?
        !muted_test_ids.empty?
      end

      private

      # Muted test case ids
      #
      # @return [Set]
      def muted_test_ids
        @muted_test_ids ||= Set.new(muted_tests&.filter_map { |test| test[:testCaseId] }).freeze
      end

      # Parsed test plan object
      #
      # @return [Hash]
      def test_plan
        @test_plan ||= load_json(test_plan_path)
      end

      # Tests to execute from allure testplan.json
      #
      # @return [Array<Hash>]
      def tests
        @tests ||= test_plan&.fetch(:tests, nil) if test_plan_path
      end

      # Tests to skip from allure testplan.json
      #
      # @return [Array<Hash>]
      def muted_tests
        @muted_tests ||= test_plan&.fetch(:mutedTests, nil) if test_plan_path
      end

      # Fetch test plan path
      #
      # @return [<String, nil>]
      def test_plan_path
        return @test_plan_path if defined?(@test_plan_path)

        @test_plan_path = ENV[TESTPLAN_PATH].then do |path|
          next unless path
          next path if File.file?(path)

          json = File.join(path, "testplan.json")
          next json if File.exist?(json)

          Allure.configuration.logger.warn("'ALLURE_TESTPLAN_PATH' env var is set, but no testplan.json found!")
          nil
        end
      end
    end
  end
end
