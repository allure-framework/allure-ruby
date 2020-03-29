# frozen_string_literal: true

describe "start" do
  include_context "allure mock"
  include_context "rspec runner"

  it "cleans allure results directory" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "spec", allure: "some_label" do |e|
          e.step(name: "test body")
        end
      end
    SPEC

    expect(lifecycle).to have_received(:clean_results_dir).once
  end
end
