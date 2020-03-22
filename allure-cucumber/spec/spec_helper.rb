# frozen_string_literal: true

require "simplecov"
require "allure-cucumber"
require "rspec"
require "pry"

require_relative "cucumber_helper"

SimpleCov.command_name("allure-cucumber")

RSpec.shared_context("allure mock") do
  let(:lifecycle) { spy("lifecycle") }

  before do
    allow(Allure).to receive(:lifecycle).and_return(lifecycle)
  end
end

RSpec.shared_context("cucumber runner") do
  let(:test_tmp_dir) { |e| "tmp/#{e.full_description.tr(' ', '_')}" }
  let(:cucumber) { CucumberHelper.new(test_tmp_dir) }

  def run_cucumber_cli(feature, *args)
    cucumber.execute(feature, args)
  end
end
