# frozen_string_literal: true

require "simplecov"
require "rspec"
require "allure-rspec"
require "climate_control"

require_relative "rspec_runner_helper"

SimpleCov.command_name("allure-rspec")

AllureRspec.configure do |c|
  c.clean_results_directory = true
end

RSpec.configure do |config|
  config.before do |example|
    example.epic("allure-rspec")
    example.parameter("ruby", ENV["RUBY_VERSION"])
    example.parameter("oj", ENV["WITH_OJ_GEM"])
  end
end

RSpec.shared_context("allure mock") do
  let(:allure_environment) { nil }
  let(:environment_properties) { { env: "test" } }
  let(:categories) { [Allure::Category.new(name: "test")] }
  let(:config) do
    AllureRspec::RspecConfig.send(:new).tap do |conf|
      conf.instance_variable_set(:@allure_config, Allure::Config.send(:new))
      conf.environment = allure_environment

      conf.results_directory = "tmp/allure-results"
      conf.link_tms_pattern = "http://www.jira.com/tms/{}"
      conf.link_issue_pattern = "http://www.jira.com/issue/{}"
      conf.ignored_tags = [:ignored]

      conf.environment_properties = environment_properties
      conf.categories = categories
    end
  end

  let(:lifecycle) { spy("lifecycle") }

  before do
    allow(Allure::AllureLifecycle).to receive(:new) { lifecycle }
    allow(AllureRspec).to receive(:configuration) { config }
  end
end

RSpec.shared_context("rspec runner") do
  let!(:test_tmp_dir) { |e| "tmp/#{e.full_description.tr(' ', '_')}" }

  before do
    configuration = RSpec::Core::Configuration.new
    world = RSpec::Core::World.new(configuration)

    allow(RSpec).to receive(:configuration).and_return(configuration)
    allow(RSpec).to receive(:world).and_return(world)
  end

  def run_rspec(spec)
    Thread.new { RspecRunner.new(test_tmp_dir).run(spec) }.join
  end
end
