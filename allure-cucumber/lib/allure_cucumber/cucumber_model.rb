# frozen_string_literal: true

require "cucumber"
require "cucumber/core"
require "digest"
require "csv"

require_relative "ast_transformer"
require_relative "tag_parser"

module Allure
  # Support class for transforming cucumber test entities in to allure model entities
  class AllureCucumberModel
    extend AstTransformer
    extend TagParser

    class << self
      # Convert to allure test result
      # @param [Cucumber::Core::Test::Case] test_case
      # @return [TestResult]
      def test_result(test_case)
        TestResult.new(
          name: test_case.name,
          description: description(test_case),
          description_html: description(test_case),
          history_id: Digest::MD5.hexdigest(test_case.inspect),
          full_name: "#{test_case.feature.name}: #{test_case.name}",
          labels: labels(test_case),
          links: links(test_case),
          parameters: parameters(test_case) || [],
          status_details: Allure::StatusDetails.new(**status_detail_tags(test_case.tags.map(&:name))),
        )
      end

      # Convert to allure step result
      # @param [Cucumber::Core::Test::Step] test_step
      # @return [StepResult]
      def step_result(test_step)
        StepResult.new(
          name: "#{step(test_step).keyword}#{test_step.text}",
          attachments: [multiline_arg_attachment(test_step)].compact,
        )
      end

      # Convert to allure step result
      # @param [Cucumber::Core::Test::Step] test_step
      # @return [StepResult]
      def fixture_result(test_step)
        location = test_step.location.to_s.split("/").last
        FixtureResult.new(name: location)
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

      # Get thread specific lifecycle
      # @return [Allure::AllureLifecycle]
      def lifecycle
        Allure.lifecycle
      end

      # @param [Cucumber::Core::Test::Case] test_case
      # @return [Array<Allure::Label>]
      def labels(test_case)
        labels = []
        labels << ResultUtils.feature_label(test_case.feature.name)
        labels << ResultUtils.package_label(test_case.feature.name)
        labels << ResultUtils.suite_label(test_case.feature.name)
        labels << ResultUtils.story_label(test_case.name)
        labels << ResultUtils.test_class_label(test_case.name)
        unless test_case.tags.empty?
          labels.push(*tag_labels(test_case.tags))
          labels << severity(test_case.tags)
        end

        labels
      end

      # @param [Cucumber::Core::Test::Case] test_case
      # @return [Array<Allure::Link>]
      def links(test_case)
        return [] unless test_case.tags

        tms_links(test_case.tags) + issue_links(test_case.tags)
      end

      # @param [Cucumber::Core::Test::Case] test_case
      # @return [Array<Allure::Parameter>]
      def parameters(test_case)
        example_row(test_case)&.values&.map { |value| Parameter.new("argument", value) }
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
        attachment = lifecycle.prepare_attachment("data-table", ContentType::CSV)
        csv = multiline_arg.raw.each_with_object([]) { |row, arr| arr.push(row.to_csv) }.join("")
        lifecycle.write_attachment(csv, attachment)
        attachment
      end

      # @param [String] multiline_arg
      # @return [String]
      def docstring_attachment(multiline_arg)
        attachment = lifecycle.prepare_attachment("docstring", ContentType::TXT)
        lifecycle.write_attachment(multiline_arg.content, attachment)
        attachment
      end
    end
  end
end
