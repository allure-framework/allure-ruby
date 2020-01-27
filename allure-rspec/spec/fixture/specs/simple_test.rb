# frozen_string_literal: true

describe "Suite" do
  before(:each) do |e|
    e.step(name: "Before hook")
  end

  after(:each) do |e|
    e.step(name: "After hook")
  end

  it "spec", allure: "some_label" do |e|
    e.step(name: "test body")
  end
end
