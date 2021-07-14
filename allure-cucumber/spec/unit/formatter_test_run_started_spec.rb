# frozen_string_literal: true

describe "on_test_run_started" do
  include_context "allure mock"
  include_context "cucumber runner"

  before do
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
    FEATURE
  end

  it "cleans results dir before starting test run" do
    expect(lifecycle).to have_received(:clean_results_dir).once
  end

  it "creates environment.properties file" do
    expect(lifecycle).to have_received(:write_environment).once
  end

  it "creates categories.json file" do
    expect(lifecycle).to have_received(:write_categories).once
  end
end
