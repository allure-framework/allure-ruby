# frozen_string_literal: true

class TestHelper
  extend AllureStepAnnotation

  step("Singleton step")
  def self.class_method; end

  step("Standard step")
  def standard_method; end

  step
  def default_name_method; end
end

describe AllureStepAnnotation do
  let(:test_helper) { TestHelper.new }

  before do
    allow(Allure).to receive(:run_step)
  end

  it "Creates step from singleton method" do
    TestHelper.class_method

    expect(Allure).to have_received(:run_step).with("Singleton step")
  end

  it "Creates step from instance method" do
    test_helper.standard_method

    expect(Allure).to have_received(:run_step).with("Standard step")
  end

  it "Creates step with default method name" do
    test_helper.default_name_method

    expect(Allure).to have_received(:run_step).with("default_name_method")
  end
end
