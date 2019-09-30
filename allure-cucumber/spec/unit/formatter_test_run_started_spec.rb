# frozen_string_literal: true

describe "CucumberFormatter.on_test_run_started" do
  include_context "allure mock"
  include_context "cucumber runner"

  it "cleans results dir before starting test run" do
    run_cucumber_cli("features/features/simple.feature")

    expect(lifecycle).to have_received(:clean_results_dir).once
  end
end
