# frozen_string_literal: true

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
        @test_ids ||= tests&.map { |test| test[:id] }
      end

      # Test names of executable tests
      #
      # @return [Array]
      def test_names
        @test_names ||= tests&.map { |test| test[:selector] }
      end

      private

      # Tests to execute from allure testplan.json
      #
      # @return [Array<Hash>]
      def tests
        @tests ||= load_json(test_plan_path)&.fetch(:tests) if test_plan_path
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
