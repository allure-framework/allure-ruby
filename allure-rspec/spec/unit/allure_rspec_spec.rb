# frozen_string_literal: true

describe AllureRspec do
  it "returns cucumber configuration" do
    expect(AllureRspec.configuration).to be_a(AllureRspec::RspecConfig)
  end

  it "yields cucumber configuration" do
    expect { |b| AllureRspec.configure(&b) }.to yield_with_args(AllureRspec::RspecConfig.instance)
  end
end
