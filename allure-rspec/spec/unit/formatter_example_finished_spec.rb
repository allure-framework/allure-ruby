# frozen_string_literal: true

describe "RSpecFormatter.example_finished" do
  include_context "allure mock"
  include_context "rspec runner"

  before do
    @test_case = Allure::TestResult.new
  end

  let(:result_utils) { Allure::ResultUtils }

  it "stops test case" do
    run_rspec("spec/fixture/specs/simple_test.rb")

    expect(lifecycle).to have_received(:stop_test_case).once
  end

  it "correctly updates passed test case" do
    run_rspec("spec/fixture/specs/simple_test.rb")

    expect(lifecycle).to have_received(:update_test_case).with(no_args).once do |&arg|
      arg.call(@test_case)
      aggregate_failures "Should update correct test case parameters" do
        expect(@test_case.stage).to eq(Allure::Stage::FINISHED)
        expect(@test_case.status).to eq(Allure::Status::PASSED)
        expect(@test_case.status_details).to eq(Allure::StatusDetails.new)
      end
    end
  end

  it "correctly updates failed test case" do
    run_rspec("spec/fixture/specs/exception_test.rb", "failed")

    expect(lifecycle).to have_received(:update_test_case).with(no_args) do |&arg|
      arg.call(@test_case)
      aggregate_failures "Should update correct test case parameters" do
        expect(@test_case.stage).to eq(Allure::Stage::FINISHED)
        expect(@test_case.status).to eq(Allure::Status::FAILED)
        expect(@test_case.status_details.message).to include("expected: 2", "got: 1")
        expect(@test_case.status_details.trace).not_to be_empty
      end
    end
  end

  it "correctly updates broken test case" do
    run_rspec("spec/fixture/specs/exception_test.rb", "broken")

    expect(lifecycle).to have_received(:update_test_case).with(no_args) do |&arg|
      arg.call(@test_case)
      aggregate_failures "Should update correct test case parameters" do
        expect(@test_case.stage).to eq(Allure::Stage::FINISHED)
        expect(@test_case.status).to eq(Allure::Status::BROKEN)
        expect(@test_case.status_details.message).to eq("Simple error!")
        expect(@test_case.status_details.trace).not_to be_empty
      end
    end
  end
end
