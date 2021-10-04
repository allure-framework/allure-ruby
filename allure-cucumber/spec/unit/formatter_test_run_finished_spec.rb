# frozen_string_literal: true

describe "on_test_run_finished" do
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

  it "creates environment.properties file" do
    expect(lifecycle).to have_received(:write_environment).once
  end
end
