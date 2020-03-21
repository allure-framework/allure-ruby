# frozen_string_literal: true

describe "allure cucumber" do
  include_context "cucumber runner"

  let(:results_dir) { Allure::Config.results_directory }

  it "generates allure json results files", integration: true do
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
        And b is 10
        When I add a to b
        Then result is 15
    FEATURE

    container = File.new(Dir["#{results_dir}/*container.json"].first)
    result = File.new(Dir["#{results_dir}/*result.json"].first)

    aggregate_failures "Results files should exist" do
      expect(File.exist?(container)).to be_truthy
      expect(File.exist?(result)).to be_truthy
    end

    container_json = JSON.parse(File.read(container), symbolize_names: true)
    result_json = JSON.parse(File.read(result), symbolize_names: true)
    aggregate_failures "Json results should contain valid data" do
      expect(container_json[:name]).to eq("Add a to b")
      expect(result_json[:description]).to eq("Simple scenario description")
      expect(result_json[:steps].size).to eq(4)
    end
  end
end
