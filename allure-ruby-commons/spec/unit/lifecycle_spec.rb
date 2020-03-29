# frozen_string_literal: true

describe Allure::AllureLifecycle do
  let(:report_files) { ["result.json", "container.json"] }
  before do
    allow(Allure.configuration).to receive(:clean_results_directory).and_return(true)
  end

  it "clean allure results directory" do
    expect(Allure.configuration).to receive(:results_directory).once
    expect(Dir).to receive(:glob).and_return(report_files).once
    expect(FileUtils).to receive(:rm_f).with(report_files).once

    Allure::AllureLifecycle.new.clean_results_dir
  end
end
