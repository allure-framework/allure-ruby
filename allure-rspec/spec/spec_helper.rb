# frozen_string_literal: true

require "rspec"
require "pry"
require "allure-ruby-commons"
require "allure-rspec"

Allure.configure do |c|
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
  before do
    configuration = RSpec::Core::Configuration.new
    world = RSpec::Core::World.new(configuration)

    allow(RSpec).to receive(:configuration).and_return(configuration)
    allow(RSpec).to receive(:world).and_return(world)
  end

  def run_rspec(spec)
    RSpec::Core::Runner.run([spec, "--format", "AllureRspecFormatter"], StringIO.new, StringIO.new)
  end
end
