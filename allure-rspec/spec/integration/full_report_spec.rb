# frozen_string_literal: true

describe "allure-rspec" do
  include_context "rspec runner"

  let(:results_dir) { Allure::Config.results_directory }

  it "Generates allure json results files", integration: true do
    run_rspec("spec/fixture/specs/simple_test.rb")

    container = File.new(Dir["#{results_dir}/*container.json"].first)
    result = File.new(Dir["#{results_dir}/*result.json"].first)

    aggregate_failures "Results files should exist" do
      expect(File.exist?(container)).to be_truthy
      expect(File.exist?(result)).to be_truthy
    end

    container_json = JSON.parse(File.read(container), symbolize_names: true)
    result_json = JSON.parse(File.read(result), symbolize_names: true)
    aggregate_failures "Json results should contain valid data" do
      expect(container_json[:name]).to eq("Suite")
      expect(result_json[:name]).to eq("spec")
      expect(result_json[:description]).to eq("Location - spec/fixture/specs/simple_test.rb:4")
      expect(result_json[:steps].size).to eq(0)
    end
  end
end
