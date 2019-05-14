# frozen_string_literal: true

describe Allure::ResultUtils do
  let(:rspec_error) { RSpec::Expectations::ExpectationNotMetError.new("Not met") }
  let(:error) { StandardError.new("Error") }

  it "returns correct status for expectation error" do
    expect(Allure::ResultUtils.status(rspec_error)).to eq(Allure::Status::FAILED)
  end

  it "returns correct status for error" do
    expect(Allure::ResultUtils.status(error)).to eq(Allure::Status::BROKEN)
  end

  it "returns status details" do
    raise error
  rescue => e
    status_details = Allure::ResultUtils.status_details(e)
    expect(status_details[:message]).to eq("Error")
    expect(status_details[:message]).not_to be_empty
  end
end
