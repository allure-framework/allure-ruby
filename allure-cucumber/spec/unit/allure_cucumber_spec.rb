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
end
