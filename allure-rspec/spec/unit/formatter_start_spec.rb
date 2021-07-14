# frozen_string_literal: true

describe "start", focus: true do
  include_context "allure mock"
  include_context "rspec runner"

  before do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "spec", allure: "some_label" do |e|
          e.step(name: "test body")
        end
      end
    SPEC
  end

  it "cleans allure results directory" do
    expect(lifecycle).to have_received(:clean_results_dir).once
  end

  it "creates environment.properties file" do
    expect(lifecycle).to have_received(:write_environment).once
  end

  it "creates categories.json file" do
    expect(lifecycle).to have_received(:write_categories).once
  end
end
