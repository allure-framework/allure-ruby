# frozen_string_literal: true

describe AllureCucumber do
  let(:cucumber_config) { AllureCucumber::CucumberConfig.send(:new) }

  before do
    allow(Allure::Config).to receive(:instance).and_return(Allure::Config.send(:new))
    allow(AllureCucumber::CucumberConfig).to receive(:instance).and_return(cucumber_config)
  end

  it "returns cucumber configuration" do
    expect(AllureCucumber.configuration).to be_a(AllureCucumber::CucumberConfig)
  end

  it "yields cucumber configuration" do
    expect { |b| AllureCucumber.configure(&b) }.to yield_with_args(cucumber_config)
  end

  it "supports common configuration options" do
    AllureCucumber.configure { |config| config.failure_exception = StandardError }

    expect(AllureCucumber.configuration.failure_exception).to eq(StandardError)
  end

  it "supports cucumber specific configuration options" do
    AllureCucumber.configure { |config| config.tms_prefix = "TMS" }

    expect(AllureCucumber.configuration.tms_prefix).to eq("TMS")
  end

  context "with global labels" do
    include_context "cucumber runner"

    it "writes configured labels to every test result alongside scenario tags" do
      global_labels = [
        { name: "owner", value: "qa" },
        { name: "label", value: "global" }
      ]
      AllureCucumber.configure { |config| config.global_labels = global_labels }

      run_cucumber_cli(<<~FEATURE)
        Feature: Global labels

        @local
        Scenario: First scenario
          Given a is 5

        Scenario: Second scenario
          Given a is 10
      FEATURE

      results_directory = AllureCucumber.configuration.results_directory
      reader = Allure::FileWriter.new(results_directory)
      results = Dir.glob(File.join(results_directory, "*-result.json")).map { |path| reader.load_json(path) }

      first = results.find { |result| result[:name] == "First scenario" }
      second = results.find { |result| result[:name] == "Second scenario" }

      expect(results.size).to eq(2)
      expect(first[:labels]).to include(*global_labels, { name: "tag", value: "local" })
      expect(second[:labels]).to include(*global_labels)
    end
  end
end
