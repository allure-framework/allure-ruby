# frozen_string_literal: true

require "simplecov"
require "rspec"
require "allure-rspec"

require_relative "rspec_runner_helper"

SimpleCov.command_name("allure-rspec")

AllureRspec.configure do |c|
  c.clean_results_directory = true
  c.link_tms_pattern = "http://www.jira.com/tms/{}"
  c.link_issue_pattern = "http://www.jira.com/issue/{}"
end

RSpec.shared_context("allure mock") do
  let(:lifecycle) { spy("lifecycle") }

  before do
    allow(Allure).to receive(:lifecycle).and_return(lifecycle)
  end
end

RSpec.shared_context("rspec runner") do
  let(:test_tmp_dir) { |e| "tmp/#{e.full_description.tr(' ', '_')}" }
  let(:rspec_runner) { RspecRunner.new(test_tmp_dir) }

  before do
    configuration = RSpec::Core::Configuration.new
    world = RSpec::Core::World.new(configuration)

    allow(RSpec).to receive(:configuration).and_return(configuration)
    allow(RSpec).to receive(:world).and_return(world)
  end

  def run_rspec(spec)
    rspec_runner.run(spec)
  end
end
