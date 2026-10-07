# frozen_string_literal: true

describe AllureRspec do
  let(:rspec_config) { AllureRspec::RspecConfig.send(:new) }

  before do
    allow(Allure::Config).to receive(:instance).and_return(Allure::Config.send(:new))
    allow(AllureRspec::RspecConfig).to receive(:instance).and_return(rspec_config)
  end

  it "returns rspec configuration" do
    expect(AllureRspec.configuration).to be_a(AllureRspec::RspecConfig)
  end

  it "yields rspec configuration" do
    expect { |b| AllureRspec.configure(&b) }.to yield_with_args(rspec_config)
  end

  it "supports common configuration options" do
    AllureRspec.configure { |config| config.failure_exception = StandardError }

    expect(AllureRspec.configuration.failure_exception).to eq(StandardError)
  end

  it "supports rspec specific configuration options" do
    AllureRspec.configure { |config| config.tms_tag = "TMS" }

    expect(AllureRspec.configuration.tms_tag).to eq("TMS")
  end

  context "with global labels" do
    include_context "rspec runner"

    it "writes configured labels to every test result alongside metadata labels" do
      results_directory = File.expand_path("#{test_tmp_dir}/allure-results")
      global_labels = [
        { name: "owner", value: "qa" },
        { name: "label", value: "global" }
      ]
      AllureRspec.configure do |config|
        config.results_directory = results_directory
        config.global_labels = global_labels
      end

      run_rspec(<<~SPEC)
        describe "Suite" do
          it("first example", tag: "local") {}
          it("second example") {}
        end
      SPEC

      reader = Allure::FileWriter.new(results_directory)
      results = Dir.glob(File.join(results_directory, "*-result.json")).map { |path| reader.load_json(path) }

      first = results.find { |result| result[:name] == "first example" }
      second = results.find { |result| result[:name] == "second example" }

      expect(results.size).to eq(2)
      expect(first[:labels]).to include(*global_labels, { name: "tag", value: "local" })
      expect(second[:labels]).to include(*global_labels)
    end
  end
end
