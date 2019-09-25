# frozen_string_literal: true

describe "RSpecFormatter.example_group_started" do
  include_context "allure mock"
  include_context "rspec runner"

  it "starts test container with correct arguments" do
    run_rspec("spec/fixture/specs/simple_test.rb")

    expect(lifecycle).to have_received(:start_test_container).once do |arg|
      expect(arg.name).to eq("Suite")
    end
  end
end
