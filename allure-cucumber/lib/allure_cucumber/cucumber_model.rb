# frozen_string_literal: true

require "cucumber"
require "cucumber/core"
require "csv"

require_relative "models/scenario"
require_relative "models/step"
require_relative "tag_parser"

module AllureCucumber
  # Support class for transforming cucumber test entities in to allure model entities
  class AllureCucumberModel
    include TagParser

    # @param [Cucumber::Configuration] config
    def initialize(config)
      @ast_lookup = Cucumber::Formatter::AstLookup.new(config)
    end

    # Convert to allure test result
    # @param [Cucumber::Core::Test::Case] test_case
    # @return [TestResult]
    def test_result(test_case)
      scenario = Scenario.new(test_case, ast_lookup)

      Allure::TestResult.new(
        name: scenario.name,
        description: scenario.description,
        description_html: scenario.description,
        history_id: scenario.id,
        full_name: "#{scenario.feature_name}: #{scenario.name}",
        labels: labels(scenario),
        links: links(scenario),
        parameters: parameters(scenario),
        status_details: Allure::StatusDetails.new(**status_detail_tags(scenario.tags)),
      )
    end

    # Convert to allure step result
    # @param [Cucumber::Core::Test::Step] test_step
    # @return [StepResult]
    def step_result(test_step)
      Allure::StepResult.new(
        name: "#{step(test_step).keyword}#{test_step.text}",
        attachments: [multiline_arg_attachment(test_step)].compact,
      )
    end

    # Convert to allure step result
    # @param [Cucumber::Core::Test::Step] test_step
    # @return [StepResult]
    def fixture_result(test_step)
      location = test_step.location.to_s.split("/").last
      Allure::FixtureResult.new(name: location)
    end

    # Get failure details
    # @param [Cucumber::Core::Test::Result] result <description>
    # @return [Hash<Symbol, String>]
    def failure_details(result)
      return { message: result.exception.message, trace: result.exception.backtrace.join("\n") } if result.failed?
      return { message: result.message, trace: result.backtrace.join("\n") } if result.undefined?

      {}
    end

    private

    attr_reader :ast_lookup

    # Get scenario
    # @param [Cucumber::Core::Test::Case] test_case
    # @return [Cucumber::Messages::GherkinDocument::Feature::Scenario]
    def scenario(test_case)
      @ast_lookup.scenario_source(test_case)
    end

    # @param [Scenario] scenario
    # @return [Array<Allure::Label>]
    def labels(scenario)
      labels = []
      labels << Allure::ResultUtils.framework_label("cucumber")
      labels << Allure::ResultUtils.feature_label(scenario.feature_name)
      labels << Allure::ResultUtils.package_label(scenario.feature_folder)
      labels << Allure::ResultUtils.suite_label(scenario.feature_name)
      labels << Allure::ResultUtils.story_label(scenario.name)
      labels << Allure::ResultUtils.test_class_label(scenario.feature_file_name)
      unless scenario.tags.empty?
        labels.push(*tag_labels(scenario.tags))
        labels << severity(scenario.tags)
      end

      labels
    end

    # @param [Cucumber::Core::Test::Case] test_case
    # @return [Array<Allure::Link>]
    def links(test_case)
      return [] unless test_case.tags

      tms_links(test_case.tags) + issue_links(test_case.tags)
    end

    # @param [AllureCucumber::Scenario] scenario
    # @return [Array<Allure::Parameter>]
    def parameters(scenario)
      scenario.examples.map { |k, v| Allure::Parameter.new(k, v) }
    end

    # @param [Cucumber::Core::Test::Case] test_case
    # @return [String]
    def description(test_case)
      scenario = scenario(test_case)
      scenario.description.empty? ? "Location - #{scenario.file_colon_line}" : scenario.description.strip
    end

    # @param [Cucumber::Core::Test::Step] test_step
    # @return [Allure::Attachment]
    def multiline_arg_attachment(test_step)
      arg = multiline_arg(test_step)
      return unless arg

      arg.data_table? ? data_table_attachment(arg) : docstring_attachment(arg)
    end

    # @param [Cucumber::Core::Ast::DataTable] multiline_arg
    # @return [Allure::Attachment]
    def data_table_attachment(multiline_arg)
      attachment = lifecycle.prepare_attachment("data-table", Allure::ContentType::CSV)
      csv = multiline_arg.raw.each_with_object([]) { |row, arr| arr.push(row.to_csv) }.join("")
      lifecycle.write_attachment(csv, attachment)
      attachment
    end

    # @param [String] multiline_arg
    # @return [String]
    def docstring_attachment(multiline_arg)
      attachment = lifecycle.prepare_attachment("docstring", Allure::ContentType::TXT)
      lifecycle.write_attachment(multiline_arg.content, attachment)
      attachment
    end
  end
end
