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

      # Match an Allure ID first, falling back to the selector and generated identity
      #
      # @param [String, Integer, nil] allure_id
      # @param [String, nil] selector file-qualified full name
      # @param [String] test_case_id
      # @return [Boolean]
      def excluded?(allure_id:, selector:, test_case_id:)
        return true if allure_id && excluded_allure_ids.include?(allure_id.to_s)
        return true if excluded_selectors.include?(selector)

        excluded_test_ids.include?(test_case_id)
      end

      # Whether the test plan contains any excluded identities
      #
      # @return [Boolean]
      def excluded_tests?
        excluded_allure_ids.any? || excluded_test_ids.any? || excluded_selectors.any?
      end

      private

      # Excluded explicit Allure ids
      #
      # @return [Set]
      def excluded_allure_ids
        @excluded_allure_ids ||= Set.new(excluded_tests&.filter_map { |test| test[:id]&.to_s }).freeze
      end

      # Excluded test case ids
      #
      # @return [Set]
      def excluded_test_ids
        @excluded_test_ids ||= Set.new(excluded_tests&.filter_map { |test| test[:testCaseId] }).freeze
      end

      # Excluded file-qualified full-name selectors
      #
      # @return [Set]
      def excluded_selectors
        @excluded_selectors ||= Set.new(excluded_tests&.filter_map { |test| test[:selector] }).freeze
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
      def excluded_tests
        @excluded_tests ||= test_plan&.fetch(:excludedTests, nil) if test_plan_path
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
