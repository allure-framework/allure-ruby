# frozen_string_literal: true

require "pry"
require "rspec"
require "allure-ruby-commons"

RSpec.shared_context("lifecycle") do
  let(:lifecycle) { Allure::AllureLifecycle.new }

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
  let(:logger) { double("Logger") }

  before do
    allow(Allure::FileWriter).to receive(:new).and_return(file_writer)
    allow(Logger).to receive(:new).and_return(logger)
  end
end
