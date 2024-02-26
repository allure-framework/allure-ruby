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
end
