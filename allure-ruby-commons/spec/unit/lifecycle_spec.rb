# frozen_string_literal: true

describe Allure::AllureLifecycle do
  subject(:lifecycle) { described_class.new(config) }

  let(:file_writer) { instance_double("Allure::FileWriter", write_environment: nil, write_categories: nil) }
  let(:results_dir) { "spec/allure-results" }
  let(:report_files) { ["result.json", "container.json"] }

  let(:clean_results) { false }
  let(:environment_properties) { nil }
  let(:categories) { nil }
  let(:config) do
    Allure::Config.send(:new).tap do |conf|
      conf.results_directory = results_dir
      conf.clean_results_directory = clean_results
      conf.environment_properties = environment_properties
      conf.categories = categories
    end
  end

  before do
    allow(Dir).to receive(:glob).and_return(report_files)
    allow(FileUtils).to receive(:rm_f).with(report_files)
    allow(Allure::FileWriter).to receive(:new) { file_writer }
  end

  context "without environment, categories and clean results config" do
    it "skips cleaning" do
      lifecycle.clean_results_dir

      expect(FileUtils).not_to have_received(:rm_f)
    end

    it "skips creating environment.properties" do
      lifecycle.write_environment

      expect(file_writer).not_to have_received(:write_environment)
    end

    it "skips creating categories.json" do
      lifecycle.write_categories

      expect(file_writer).not_to have_received(:write_categories)
    end
  end

  context "with environment, categories and clean results config" do
    let(:clean_results) { true }
    let(:categories) { [Allure::Category.new(name: "test")] }
    let(:env_properties_hash) { { test: "test" } }

    it "cleans allure results directory" do
      lifecycle.clean_results_dir

      expect(Dir).to have_received(:glob).with("#{results_dir}/**/*")
      expect(FileUtils).to have_received(:rm_f).with(report_files)
    end

    it "creates categories.json" do
      lifecycle.write_categories

      expect(file_writer).to have_received(:write_categories).with(categories)
    end

    context "with environment_properties hash configuration" do
      let(:environment_properties) { env_properties_hash }

      it "creates environment.properties" do
        lifecycle.write_environment

        expect(file_writer).to have_received(:write_environment).with(env_properties_hash)
      end
    end

    context "with environment_properties lambda configuration" do
      let(:environment_properties) { -> { env_properties_hash } }

      it "creates environment.properties" do
        lifecycle.write_environment

        expect(file_writer).to have_received(:write_environment).with(env_properties_hash)
      end
    end
  end
end
