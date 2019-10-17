# frozen_string_literal: true

describe Allure::ResultUtils do
  let(:rspec_error) { RSpec::Expectations::ExpectationNotMetError.new("Not met") }
  let(:error) { StandardError.new("Error") }

  def raise_multi_error
    aggregate_failures do
      expect(1).to eq(2)
      expect("1").to eq("2")
    end
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
  rescue => e
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
