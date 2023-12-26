# frozen_string_literal: true

ENV["ALLURE_LOG_LEVEL"] = "FATAL"

require "simplecov"
require "rspec"
require "climate_control"
require "allure-ruby-commons"
require "allure-rspec"

SimpleCov.command_name("allure-ruby-commons")

AllureRspec.configure do |c|
  c.clean_results_directory = true
end

RSpec.configure do |config|
  config.before do |example|
    example.epic("allure-ruby-commons")
    example.parameter("ruby", ENV["RUBY_VERSION"])
    example.parameter("oj", ENV["WITH_OJ_GEM"])
  end
end

RSpec.shared_context("lifecycle mocks") do
  let(:lifecycle) { Allure::AllureLifecycle.new(config) }
  let(:config) do
    Allure::Config.send(:new).tap do |conf|
      conf.results_directory = "spec/allure-results"
      conf.environment = nil
    end
  end

  let(:file_writer) do
    instance_double(
      "FileWriter",
      write_attachment: nil,
      write_categories: nil,
      write_environment: nil,
      write_test_result: nil,
      write_test_result_container: nil
    )
  end

  before do
    allow(Allure::FileWriter).to receive(:new).and_return(file_writer)
  end

  def start_test_container(name)
    lifecycle.start_test_container(Allure::TestResultContainer.new(name: name))
  end

  def start_fixture(name, type)
    lifecycle.public_send(:"start_#{type}_fixture", Allure::FixtureResult.new(name: name))
  end

  def add_fixture(name, type)
    fixture_result = lifecycle.public_send(:"start_#{type}_fixture", Allure::FixtureResult.new(name: name))
    lifecycle.update_fixture { |fixture| fixture.status = Allure::Status::PASSED }
    lifecycle.stop_fixture

    fixture_result
  end

  def start_test_case(**options)
    lifecycle.start_test_case(Allure::TestResult.new(**options))
  end

  def start_test_step(**options)
    lifecycle.start_test_step(Allure::StepResult.new(**options))
  end
end

def clean_results_dir
  FileUtils.rm_rf("spec/allure-results")
end
