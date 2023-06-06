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
    example.parameter("ruby", ENV["RUBY_VERSION"])
    example.parameter("oj", ENV["WITH_OJ_GEM"])
  end
end

RSpec.shared_context("allure mock") do
  let(:allure_environment) { nil }
  let(:config) do
    AllureCucumber::CucumberConfig.send(:new).tap do |conf|
      conf.instance_variable_set(:@allure_config, Allure::Config.send(:new))
      conf.environment = allure_environment

      conf.link_tms_pattern = "http://www.jira.com/tms/{}"
      conf.link_issue_pattern = "http://www.jira.com/issue/{}"
    end
  end
  let(:lifecycle) { spy("lifecycle") }

  before do
    allow(Allure::AllureLifecycle).to receive(:new) { lifecycle }
    allow(AllureCucumber).to receive(:configuration) { config }
  end
end

RSpec.shared_context("cucumber runner") do
  let!(:test_tmp_dir) { |e| "tmp/#{e.full_description.tr(' ', '_')}" }

  def run_cucumber_cli(feature)
    Thread.new { CucumberHelper.new(test_tmp_dir).execute(feature) }.join
  end
end
