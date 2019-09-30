# frozen_string_literal: true

describe "RSpecFormatter.example_group_finished" do
  include_context "allure mock"
  include_context "rspec runner"

  it "stops test container" do
    run_rspec("spec/fixture/specs/simple_test.rb")

    expect(lifecycle).to have_received(:stop_test_container).once
  end
end
