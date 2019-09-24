# frozen_string_literal: true

describe "Allure formatter" do
  include_context "allure mock"
  include_context "rspec runner"

  it "Cleans allure results directory" do
    run_rspec("spec/fixture/specs/simple_test.rb")

    expect(lifecycle).to have_received(:clean_results_dir).once
  end
end
