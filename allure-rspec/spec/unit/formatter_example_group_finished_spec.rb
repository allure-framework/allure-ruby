# frozen_string_literal: true

describe "example_group_finished" do
  include_context "allure mock"
  include_context "rspec runner"

  it "stops test container" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "spec", allure: "some_label" do |e|
          e.step(name: "test body")
        end
      end
    SPEC

    expect(lifecycle).to have_received(:stop_test_container).once
  end
end
