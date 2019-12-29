# rubocop:disable Naming/FileName
# frozen_string_literal: true

require "require_all"
require "uuid"
require_rel "allure_ruby_commons/**/*rb"

# Namespace for classes that handle allure report generation and different framework adaptors
module Allure
  class << self
    # Get thread specific allure lifecycle object
    # @return [Allure::AllureLifecycle]
    def lifecycle
      Thread.current[:lifecycle] ||= AllureLifecycle.new
    end

    # Set lifecycle object
    # @param [Allure::AllureLifecycle] lifecycle
    # @return [void]
    def lifecycle=(lifecycle)
      Thread.current[:lifecycle] = lifecycle
    end

    # Get allure configuration
    # @return [Allure::Config]
    def configuration
      Config
    end

    # Set allure configuration
    # @yieldparam [Allure::Config]
    # @yieldreturn [void]
    # @return [void]
    def configure
      yield(Config)
    end

    # Add epic to current test case
    # @param [String] value
    # @return [void]
    def epic(value)
      label(ResultUtils::EPIC_LABEL_NAME, value)
    end

    # Add feature to current test case
    # @param [String] value
    # @return [void]
    def feature(value)
      label(ResultUtils::FEATURE_LABEL_NAME, value)
    end

    # Add story to current test case
    # @param [String] value
    # @return [void]
    def story(value)
      label(ResultUtils::STORY_LABEL_NAME, value)
    end

    # Add suite to current test case
    # @param [String] value
    # @return [void]
    def suite(value)
      label(ResultUtils::SUITE_LABEL_NAME, value)
    end

    # Add label to current test case
    # @param [String] name
    # @param [String] value
    # @return [void]
    def label(name, value)
      lifecycle.update_test_case do |test_case|
        test_case.labels.push(Label.new(name, value))
      end
    end

    # Add description to current test case
    # @param [String] description
    # @return [void]
    def add_description(description)
      lifecycle.update_test_case do |test_case|
        test_case.description = description
      end
    end

    # Add html description to current test case
    # @param [String] description_html
    # @return [void]
    def description_html(description_html)
      lifecycle.update_test_case do |test_case|
        test_case.description_html = description_html
      end
    end

    # Add parameter to current test case
    # @param [String] name
    # @param [String] value
    # @return [void]
    def parameter(name, value)
      lifecycle.update_test_case do |test_case|
        test_case.parameters.push(Parameter.new(name, value))
      end
    end

    # Add tms link to current test case
    # @param [String] name
    # @param [String] url
    # @return [void]
    def tms(name, url)
      add_link(name: name, url: url, type: ResultUtils::TMS_LINK_TYPE)
    end

    # Add issue linkt to current test case
    # @param [String] name
    # @param [String] url
    # @return [void]
    def issue(name, url)
      add_link(name: name, url: url, type: ResultUtils::ISSUE_LINK_TYPE)
    end

    # Add link to current test case
    # @param [String ] url
    # @param [String] name
    # @param [String] type type of the link used to display link icon
    # @return [void]
    def add_link(url:, name: nil, type: "custom")
      lifecycle.update_test_case do |test_case|
        test_case.links.push(Link.new(type, name || url, url))
      end
    end

    # Add attachment to current test case or step
    # @param [String] name Attachment name
    # @param [File, String] source File or string to save as attachment
    # @param [String] type attachment type defined in {Allure::ContentType} or any other valid mime type
    # @param [Boolean] test_case add attachment to current test case instead of test step
    # @return [void]
    def add_attachment(name:, source:, type:, test_case: false)
      lifecycle.add_attachment(name: name, source: source, type: type, test_case: test_case)
    end

    # Add allure report environment info
    # @param [Hash<Symbol, String>] environment
    # @return [void]
    def add_environment(environment)
      lifecycle.write_environment(environment)
    end

    # Add categories info
    # @param [File, Array<Allure::Category>] categories
    # @return [void]
    def add_categories(categories)
      lifecycle.write_categories(categories)
    end

    # Add step with provided name and optional status to current test step, fixture or test case
    # @param [String] name
    # @param [Symbol] status <Allure::Status>, <Allure::Status::PASSED> by default
    # @return [void]
    def step(name:, status: nil)
      lifecycle.add_test_step(StepResult.new(name: name, status: status || Status::PASSED, stage: Stage::FINISHED))
    end

    # Run passed block as step with given name
    # @param [String] name
    # @yield [] step block
    # @return [void]
    def run_step(name)
      lifecycle.start_test_step(StepResult.new(name: name, stage: Stage::RUNNING))
      yield
      lifecycle.update_test_step { |step| step.status = Status::PASSED }
    rescue => e
      lifecycle.update_test_step do |step|
        step.status = ResultUtils.status(e)
        step.status_details = ResultUtils.status_details(e)
      end
      raise(e)
    ensure
      lifecycle.stop_test_step
    end
  end
end
# rubocop:enable Naming/FileName
