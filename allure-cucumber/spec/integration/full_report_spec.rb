# frozen_string_literal: true

describe "allure-cucumber" do
  include_context "cucumber runner"

  let(:allure_cli) { Allure::Util.allure_cli }

  before(:all) do
    if File.exist?(Allure::CucumberConfig.results_directory)
      FileUtils.remove_dir(Allure::CucumberConfig.results_directory)
    end
  end

  it "Allure commandline generates report", integration: true do
    run_cucumber_cli("features/features")

    expect(`#{allure_cli} generate -c #{Allure::CucumberConfig.results_directory} -o reports/allure-report`.chomp).to(
      eq("Report successfully generated to reports/allure-report"),
    )
  end
end
