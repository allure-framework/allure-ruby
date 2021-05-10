# frozen_string_literal: true

module Allure
  class TestPlan
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
        @tests ||= Oj.load_file(ENV[TESTPLAN_PATH], symbol_keys: true)&.fetch(:tests) if ENV[TESTPLAN_PATH]
      rescue Oj::ParseError
        nil
      end
    end
  end
end
