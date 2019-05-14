# frozen_string_literal: true

describe "AllureLifecycle::TestStepResult" do
  include_context "lifecycle"
  include_context "lifecycle mocks"

  context "without exceptions" do
    before do
      @result_container = start_test_container("Test Container")
      @test_case = start_test_case(name: "Test case", full_name: "Full name")
      @test_step = start_test_step(name: "Step name", descrption: "step description")

      allow(Allure::FileWriter).to receive(:new).and_return(file_writer)
    end

    it "starts test step" do
      aggregate_failures "should start test step and add to test case" do
        expect(@test_step.start).to be_a(Numeric)
        expect(@test_case.steps.last).to eq(@test_step)
      end
    end

    it "updates test step" do
      lifecycle.update_test_step { |step| step.status = Allure::Status::SKIPPED }

      expect(@test_step.status).to eq(Allure::Status::SKIPPED)
    end

    it "stops test step" do
      lifecycle.stop_test_step

      aggregate_failures "Should update parameters" do
        expect(@test_step.stop).to be_a(Numeric)
        expect(@test_step.stage).to eq(Allure::Stage::FINISHED)
      end
    end
  end

  context "logs error" do
    it "no running test case" do
      expect(logger).to receive(:error).with(/no test case is running/)

      start_test_step(name: "Step name", descrption: "step description")
    end

    it "no running test step" do
      start_test_container("Test Container")
      start_test_case(name: "Test case", full_name: "Full name")

      expect(logger).to receive(:error).with(/no step is running/)
      expect(logger).to receive(:error).with(/no step is running/)

      lifecycle.update_test_step { |step| step.name = "Test" }
      lifecycle.stop_test_step
    end
  end
end
