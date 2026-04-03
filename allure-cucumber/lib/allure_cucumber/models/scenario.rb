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

    # Title path without the final scenario display name.
    # @return [Array<String>]
    def title_path
      [feature_path, feature_name, rule_name].compact
    end

    # Scenario name
    # @return [String]
    def name
      @name ||= scenario_outline? ? "#{scenario.name}, #{example_row}" : scenario.name
    end

    # Scenario description or it's location
    # @return [String]
    def description
      @description ||= scenario.description.empty? ? "Location - #{test_case.location}" : scenario.description.strip
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
      @feature_file_name ||= File.basename(location_file, ".feature")
    end

    # Feature folder
    # @return [String]
    def feature_folder
      @feature_folder ||= begin
        directory = File.dirname(location_file)
        directory == "." ? nil : File.basename(directory)
      end
    end

    private

    attr_reader :test_case, :scenario_source, :feature

    # @return [String]
    def feature_path
      @feature_path ||= location_file.delete_prefix("./")
    end

    # @return [String]
    def location_file
      @location_file ||= test_case.location.file
    end

    # @return [String, nil]
    def rule_name
      @rule_name ||= rule&.name
    end

    # @return [Object, nil]
    def rule
      return unless scenario_id

      @rule ||= Array(feature.children)
                 .filter_map { |child| child.rule if child.respond_to?(:rule) }
                 .find { |child_rule| rule_scenario_ids(child_rule).include?(scenario_id) }
    end

    # @return [Array<String>]
    def rule_scenario_ids(rule)
      Array(rule.children).filter_map do |child|
        next unless child.respond_to?(:scenario)

        child.scenario&.id
      end
    end

    # @return [String, nil]
    def scenario_id
      @scenario_id ||= scenario.respond_to?(:id) ? scenario.id : nil
    end

    # Is scenario outline
    # @return [Boolean]
    def scenario_outline?
      scenario_source.type == :ScenarioOutline
    end

    # Cucumber scenario object
    # @return [
    #   Cucumber::Messages::GherkinDocument::Feature::Scenario,
    #   Cucumber::Messages::GherkinDocument::Feature::ScenarioOutline
    # ]
    def scenario
      @scenario ||= scenario_outline? ? scenario_source.scenario_outline : scenario_source.scenario
    end

    # Scenario outline example row
    # @return [String]
    def example_row
      @example_row ||= begin
        scneario_examples = scenario_source.examples.table_body.index { |row| row.id == scenario_source.row.id } + 1

        "Examples (##{scneario_examples})"
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
