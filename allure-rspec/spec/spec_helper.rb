# frozen_string_literal: true

require "rspec"
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

  def run_rspec(spec, tag = nil)
    [spec, "--format", "AllureRspecFormatter"].tap do |args|
      args.push("--tag", tag) if tag
      RSpec::Core::Runner.run(args, StringIO.new, StringIO.new)
    end
  end
end
