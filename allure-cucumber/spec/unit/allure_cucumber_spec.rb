# frozen_string_literal: true

describe AllureCucumber do
  it "returns cucumber configuration" do
    expect(AllureCucumber.configuration).to be(AllureCucumber::CucumberConfig.instance)
  end

  it "yields cucumber configuration" do
    expect { |b| AllureCucumber.configure(&b) }.to yield_with_args(AllureCucumber::CucumberConfig.instance)
  end
end
