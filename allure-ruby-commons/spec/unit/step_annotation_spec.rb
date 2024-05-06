# frozen_string_literal: true

class TestHelper
  extend AllureStepAnnotation

  step("Singleton step")
  def self.class_method(arg)
    "class_method: #{arg}"
  end

  step("Standard step")
  def standard_method(keyword_arg:)
    "standard_method: #{keyword_arg}"
  end

  step
  def default_name_method
    "default_name"
  end
end

describe AllureStepAnnotation do
  let(:test_helper) { TestHelper.new }

  before do
    allow(Allure).to receive(:run_step).and_yield
  end

  it "Creates step from singleton method" do
    expect(TestHelper.class_method("test")).to eq("class_method: test")
    expect(Allure).to have_received(:run_step).with("Singleton step")
  end

  it "Creates step from instance method" do
    expect(test_helper.standard_method(keyword_arg: "value")).to eq("standard_method: value")
    expect(Allure).to have_received(:run_step).with("Standard step")
  end

  it "Creates step with default method name" do
    expect(test_helper.default_name_method).to eq("default_name")
    expect(Allure).to have_received(:run_step).with("default_name_method")
  end
end
