# frozen_string_literal: true

describe Allure::ResultUtils do
  let(:rspec_error) { RSpec::Expectations::ExpectationNotMetError.new("Not met") }
  let(:error) { StandardError.new("Error") }
  let(:utils) { Allure::ResultUtils }

  def raise_multi_error
    aggregate_failures do
      expect(1).to eq(2)
      expect("1").to eq("2")
    end
  end

  it "returns framework label" do
    expect(utils.framework_label("rspec")).to eq(Allure::Label.new("framework", "rspec"))
  end

  it "returns feature label" do
    expect(utils.feature_label("feature")).to eq(Allure::Label.new("feature", "feature"))
  end

  it "returns story label" do
    expect(utils.story_label("story")).to eq(Allure::Label.new("story", "story"))
  end

  it "returns package label" do
    expect(utils.package_label("package")).to eq(Allure::Label.new("package", "package"))
  end

  it "returns test class label label" do
    expect(utils.test_class_label("testClass")).to eq(Allure::Label.new("testClass", "testClass"))
  end

  it "returns parent suite label" do
    expect(utils.parent_suite_label("parentSuite")).to eq(Allure::Label.new("parentSuite", "parentSuite"))
  end

  it "returns sub suite label" do
    expect(utils.sub_suite_label("subSuite")).to eq(Allure::Label.new("subSuite", "subSuite"))
  end

  it "returns tag label" do
    expect(utils.tag_label("tag")).to eq(Allure::Label.new("tag", "tag"))
  end

  it "returns correct status for expectation error" do
    expect(Allure::ResultUtils.status(rspec_error)).to eq(Allure::Status::FAILED)
  end

  it "returns correct status for aggregated error" do
    raise_multi_error
  rescue RSpec::Expectations::MultipleExpectationsNotMetError => e
    expect(Allure::ResultUtils.status(e)).to eq(Allure::Status::FAILED)
  end

  it "returns correct status for error" do
    expect(Allure::ResultUtils.status(error)).to eq(Allure::Status::BROKEN)
  end

  it "returns status details for simple error" do
    raise error
  rescue StandardError => e
    status_details = Allure::ResultUtils.status_details(e)
    expect(status_details.message).to eq("Error")
    expect(status_details.trace).not_to be_empty
  end

  it "returns status details for aggregated error" do
    raise_multi_error
  rescue RSpec::Expectations::MultipleExpectationsNotMetError => e
    status_details = Allure::ResultUtils.status_details(e)
    expect(status_details.message).to include("Got 2 failures from failure aggregation block")
    expect(status_details.trace).not_to be_empty
  end
end
