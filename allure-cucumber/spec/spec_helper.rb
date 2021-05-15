# frozen_string_literal: true

require "simplecov"
require "rspec"
require "allure-cucumber"
require "allure-rspec"
require "climate_control"

require_relative "cucumber_helper"

SimpleCov.command_name("allure-cucumber")

AllureRspec.configure do |c|
  c.clean_results_directory = true
end

RSpec.configure do |config|
  config.before do |example|
    example.epic("allure-cucumber")
  end
end

RSpec.shared_context("allure mock") do
  let(:config) do
    AllureCucumber::CucumberConfig.send(:new).tap do |conf|
      conf.instance_variable_set(:@allure_config, Allure::Config.send(:new))

      conf.results_directory = "tmp/allure-results"
      conf.link_tms_pattern = "http://www.jira.com/tms/{}"
      conf.link_issue_pattern = "http://www.jira.com/issue/{}"
    end
  end
  let(:lifecycle) { spy("lifecycle", config: config) }

  before do
    allow(Allure::AllureLifecycle).to receive(:new) { lifecycle }
  end
end

RSpec.shared_context("cucumber runner") do
  let!(:test_tmp_dir) { |e| "tmp/#{e.full_description.tr(' ', '_')}" }

  def run_cucumber_cli(feature)
    Thread.new { CucumberHelper.new(test_tmp_dir).execute(feature) }.join
  end
end
