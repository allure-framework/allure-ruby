# frozen_string_literal: true

describe "example_finished" do
  include_context "allure mock"
  include_context "rspec runner"

  before do
    @test_case = Allure::TestResult.new
  end

  let(:result_utils) { Allure::ResultUtils }

  it "stops test case" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "spec", allure: "some_label" do |e|
          e.step(name: "test body")
        end
      end
    SPEC

    expect(lifecycle).to have_received(:stop_test_case).once
  end

  it "correctly updates passed test case" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "spec", allure: "some_label" do |e|
          e.step(name: "test body")
        end
      end
    SPEC

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
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "failed expectation" do
          expect(1).to eq(2)
        end
      end
    SPEC

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
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "broken expectation" do
          raise Exception.new("Simple error!")
        end
      end
    SPEC

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
