# frozen_string_literal: true

require "csv"
require "cucumber/core"
require "cucumber/formatter/ast_lookup"

module AllureCucumber
  # Support class for transforming cucumber test entities in to allure model entities
  class AllureCucumberModel
    # @param [Cucumber::Configuration] config
    def initialize(config, allure_config)
      @ast_lookup = Cucumber::Formatter::AstLookup.new(config)
      @config = allure_config
    end

    # Convert to allure test result
    # @param [Cucumber::Core::Test::Case] test_case
    # @return [Allure::TestResult]
    def test_result(test_case)
      scenario = Scenario.new(test_case, ast_lookup)
      parser = MetadataParser.new(scenario, config)

      Allure::TestResult.new(
        name: scenario.name,
        description: scenario.description,
        description_html: scenario.description,
        history_id: scenario.id,
        full_name: scenario.name,
        labels: parser.labels,
        links: parser.links,
        parameters: parser.parameters,
        status_details: parser.status_details,
        environment: config.environment
      )
    end

    # Convert to allure step result
    # @param [Cucumber::Core::Test::Step] test_step
    # @return [Hash]
    def step_result(test_step)
      step = Step.new(ast_lookup.step_source(test_step))
      attachments = step_attachments(step)
      allure_step = Allure::StepResult.new(
        name: step.name,
        attachments: attachments.map { |att| att[:allure_attachment] }
      )

      { allure_step: allure_step, attachments: attachments }
    end

    # Convert to allure step result
    # @param [Cucumber::Core::Test::HookStep] hook_step
    # @return [Allure::StepResult]
    def fixture_result(hook_step)
      Allure::FixtureResult.new(name: "#{hook_step.text} (#{hook_step.location.to_s.split('/').last})")
    end

    # Get failure details
    # @param [Cucumber::Core::Test::Result] result
    # @return [Hash<Symbol, String>]
    def failure_details(result)
      return { message: result.exception.message, trace: result.exception.backtrace.join("\n") } if result.failed?
      return { message: result.message, trace: result.backtrace.join("\n") } if result.undefined?

      {}
    end

    private

    attr_reader :ast_lookup, :config

    # @param [Step] step
    # @return [Array<Allure::Attachment>]
    def step_attachments(step)
      [data_table_attachment(step), docstring_attachment(step)].compact
    end

    # @param [Step] step
    # @return [Allure::Attachment]
    def data_table_attachment(step)
      return unless step.data_table

      attachment = Allure::ResultUtils.prepare_attachment("data-table", Allure::ContentType::CSV)
      csv = step.data_table.rows.each_with_object([]) { |row, arr| arr.push(row.cells.map(&:value).to_csv) }.join
      { source: csv, allure_attachment: attachment }
    end

    # @param [Step] step
    # @return [String]
    def docstring_attachment(step)
      return unless step.doc_string

      attachment = Allure::ResultUtils.prepare_attachment("docstring", Allure::ContentType::TXT)
      { source: step.doc_string.content, allure_attachment: attachment }
    end
  end
end
