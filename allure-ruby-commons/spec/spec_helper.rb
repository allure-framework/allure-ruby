# frozen_string_literal: true

ENV["ALLURE_LOG_LEVEL"] = "FATAL"

require "simplecov"
require "rspec"
require "climate_control"
require "allure-ruby-commons"
require "pry"

SimpleCov.command_name("allure-ruby-commons")

RSpec.shared_context("lifecycle") do
  let(:config) { Allure::Config.send(:new).tap { |conf| conf.results_directory = "spec/allure-results" } }
  let(:lifecycle) { Allure::AllureLifecycle.new(config) }

  def start_test_container(name)
    lifecycle.start_test_container(Allure::TestResultContainer.new(name: name))
  end

  def start_fixture(name, type)
    lifecycle.public_send("start_#{type}_fixture", Allure::FixtureResult.new(name: name))
  end

  def add_fixture(name, type)
    fixture_result = lifecycle.public_send("start_#{type}_fixture", Allure::FixtureResult.new(name: name))
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

RSpec.shared_context("lifecycle mocks") do
  let(:file_writer) { double("FileWriter") }

  before do
    allow(Allure::FileWriter).to receive(:new).and_return(file_writer)
  end
end

def clean_results_dir
  FileUtils.remove_dir("spec/allure-results") if File.exist?("spec/allure-results")
end
