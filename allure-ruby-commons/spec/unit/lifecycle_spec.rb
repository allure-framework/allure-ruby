# frozen_string_literal: true

describe Allure::AllureLifecycle do
  subject(:lifecycle) do
    described_class.new(
      Allure::Config.send(:new).tap do |conf|
        conf.results_directory = results_dir
        conf.clean_results_directory = true
      end
    )
  end

  let(:results_dir) { "spec/allure-results" }
  let(:report_files) { ["result.json", "container.json"] }

  before do
    allow(Dir).to receive(:glob).and_return(report_files)
    allow(FileUtils).to receive(:rm_f).with(report_files)
  end

  it "clean allure results directory" do
    lifecycle.clean_results_dir

    expect(Dir).to have_received(:glob).with("#{results_dir}/**/*")
    expect(FileUtils).to have_received(:rm_f).with(report_files)
  end
end
