# frozen_string_literal: true

describe "Suite" do
  it "failed expectation", failed: true do
    expect(1).to eq(2)
  end

  it "broken expectation", broken: true do
    raise Exception.new("Simple error!")
  end
end
