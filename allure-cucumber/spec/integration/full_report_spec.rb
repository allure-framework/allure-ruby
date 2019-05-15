# frozen_string_literal: true

describe "allure-cucumber" do
  include_context "cucumber runner"

  let(:allure_cli) { Allure::Util.allure_cli }
  let(:results_dir) { Allure::CucumberConfig.results_directory }

  before(:each) do
    FileUtils.remove_dir(results_dir) if File.exist?(results_dir)
  end

  it "Generates allure json results files", integration: true do
    run_cucumber_cli("features/features/simple.feature")

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

  it "Allure commandline generates report", reporter: true do
    run_cucumber_cli("features/features")

    expect(`#{allure_cli} generate -c #{results_dir} -o reports/allure-report`.chomp).to(
      eq("Report successfully generated to reports/allure-report"),
    )
  end
end
