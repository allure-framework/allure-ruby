# frozen_string_literal: true

describe "on_test_case_finished" do
  include_context "allure mock"
  include_context "cucumber runner"

  before do
    @test_case = Allure::TestResult.new
  end

  it "stops test container and test case", cov: true do
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
    FEATURE

    expect(lifecycle).to have_received(:stop_test_case).with(no_args).once
    expect(lifecycle).to have_received(:stop_test_container).once
  end

  it "correctly updates passed test case" do
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
    FEATURE

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
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
        And b is 10
        When I add a to b
        Then result is 16
    FEATURE

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
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
        And b is 10
        When I add a to b
        Then step fails with simple exception
        And this step shoud be skipped
    FEATURE

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
