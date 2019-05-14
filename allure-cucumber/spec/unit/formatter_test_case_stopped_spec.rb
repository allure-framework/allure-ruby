# frozen_string_literal: true

describe "CucumberFormatter.on_test_case_finished" do
  include_context "allure mock"
  include_context "cucumber runner"

  before do
    @test_case = Allure::TestResult.new
  end

  it "stops test container and test case" do
    run_cucumber_cli("features/features/simple.feature")

    expect(lifecycle).to have_received(:stop_test_case).with(no_args).once
    expect(lifecycle).to have_received(:stop_test_container).once
  end

  it "correctly updates passed test case" do
    run_cucumber_cli("features/features/simple.feature")

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
    run_cucumber_cli("features/features/exception.feature", "--tags", "@failed")

    expect(lifecycle).to have_received(:update_test_case).with(no_args) do |&arg|
      arg.call(@test_case)
      aggregate_failures "Should update correct test case parameters" do
        expect(@test_case.stage).to eq(Allure::Stage::FINISHED)
        expect(@test_case.status).to eq(Allure::Status::FAILED)
        expect(@test_case.status_details.message).to include("expected: 16", "got: 15")
        expect(@test_case.status_details.trace).not_to be_empty
      end
    end
  end

  it "correctly updates broken test case" do
    run_cucumber_cli("features/features/exception.feature", "--tags", "@broken")

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
