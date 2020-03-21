# frozen_string_literal: true

require "digest"

module AllureCucumber
  # Cucumber scenario wrapper class
  class Scenario
    # @param [Cucumber::Core::Test::Case] test_case
    # @param [Cucumber::Formatter::AstLookup] ast_lookup
    def initialize(test_case, ast_lookup)
      @test_case = test_case
      @feature = ast_lookup.gherkin_document(test_case.location.file).feature
      @scenario_source = ast_lookup.scenario_source(test_case)
    end

    # Unique scenario id
    # @return [String]
    def id
      @id ||= Digest::MD5.hexdigest(test_case.inspect)
    end

    # Feature name scenario belongs to
    # @return [String]
    def feature_name
      @feature_name ||= feature.name
    end

    # Scenario name
    # @return [String]
    def name
      @name ||= scenario_outline? ? "#{scenario.name}, #{example_row}" : scenario.name
    end

    # Scenario description or it's location
    # @return [String]
    def description
      @description ||= scenario.description.empty? ? test_case.location.file : scenario.description.strip
    end

    # Scenario outline row parameters
    # @return [Hash<String, String>]
    def examples
      @examples ||= scenario_outline? ? outline_parameters : {}
    end

    # Scenario tags
    # @return [Array<String>]
    def tags
      @tags ||= test_case.tags.map(&:name)
    end

    # Feature file name
    # @return [String]
    def feature_file_name
      @feature_file_name ||= test_case.location.file.split("/").last.gsub(".feature", "")
    end

    # Feature folder
    # @return [String]
    def feature_folder
      @feature_folder ||= test_case.location.file.split("/")[-2]
    end

    private

    attr_reader :test_case, :scenario_source, :feature

    # Is scenario outline
    # @return [Boolean]
    def scenario_outline?
      scenario_source.type == :ScenarioOutline
    end

    # Cucumber scenario object
    # @return [Cucumber::Messages::GherkinDocument::Feature::Scenario]
    def scenario
      @scenario ||= scenario_outline? ? scenario_source.scenario_outline : scenario_source.scenario
    end

    # Scenario outline example row
    # @return [String]
    def example_row
      @example_row ||= begin
        "Examples (##{scenario_source.examples.table_body.index { |row| row.id == scenario_source.row.id } + 1})"
      end
    end

    # Scenario outline row parameters
    # @return [Hash<String, String>]
    def outline_parameters
      @outline_parameters ||= begin
        names = scenario_source.examples.table_header.cells.map(&:value)
        values = scenario_source.row.cells.map(&:value)
        names.zip(values).to_h
      end
    end
  end
end
