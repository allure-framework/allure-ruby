# frozen_string_literal: true

describe "example_group_started" do
  include_context "allure mock"
  include_context "rspec runner"

  it "starts test container with correct arguments" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "spec", allure: "some_label" do |e|
          e.step(name: "test body")
        end
      end
    SPEC

    expect(lifecycle).to have_received(:start_test_container).once do |arg|
      expect(arg.name).to eq("Suite")
    end
  end
end
