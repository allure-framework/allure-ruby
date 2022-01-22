# frozen_string_literal: true

describe "AllureLifecycle::TestStepResult" do
  include_context "lifecycle mocks"

  context "without exceptions" do
    before do
      @result_container = start_test_container("Test Container")
      @test_case = start_test_case(name: "Test case", full_name: "Full name")
      @test_step = start_test_step(name: "Step name", descrption: "step description")
    end

    it "starts test step" do
      aggregate_failures "should start test step and add to test case" do
        expect(@test_step.start).to be_a(Numeric)
        expect(@test_case.steps.last).to eq(@test_step)
      end
    end

    it "starts nested step" do
      start_test_step(name: "Nested step name", descrption: "step description")
      expect(@test_step.steps.last.name).to eq("Nested step name")
    end

    it "updates test step" do
      lifecycle.update_test_step { |step| step.status = Allure::Status::SKIPPED }

      expect(@test_step.status).to eq(Allure::Status::SKIPPED)
    end

    it "updates nested step" do
      start_test_step(name: "Nested step name", descrption: "step description")
      lifecycle.update_test_step { |step| step.status = Allure::Status::SKIPPED }

      aggregate_failures "steps should have correct status" do
        expect(@test_step.steps.last.status).to eq(Allure::Status::SKIPPED)
        expect(@test_step.status).to eq(Allure::Status::BROKEN) # default status for unfinished step
      end
    end

    it "stops test step" do
      lifecycle.stop_test_step

      aggregate_failures "Should update parameters" do
        expect(@test_step.stop).to be_a(Numeric)
        expect(@test_step.stage).to eq(Allure::Stage::FINISHED)
      end
    end

    it "stops nested step" do
      start_test_step(name: "Nested step name", descrption: "step description")
      lifecycle.stop_test_step

      aggregate_failures "should have stopped only nested step" do
        expect(@test_step.steps.last.stage).to eq(Allure::Stage::FINISHED)
        expect(@test_step.stage).to eq(Allure::Stage::RUNNING)
      end
    end

    it "stops parent step" do
      start_test_step(name: "Nested step name", descrption: "step description")
      lifecycle.stop_test_step
      lifecycle.stop_test_step

      aggregate_failures "should have stopped both steps" do
        expect(@test_step.steps.last.stage).to eq(Allure::Stage::FINISHED)
        expect(@test_step.stage).to eq(Allure::Stage::FINISHED)
      end
    end
  end

  context "logs error" do
    it "no running test case" do
      start_test_step(name: "Step name", descrption: "step description")
    end

    it "no running test step" do
      start_test_container("Test Container")
      start_test_case(name: "Test case", full_name: "Full name")

      lifecycle.update_test_step { |step| step.name = "Test" }
      lifecycle.stop_test_step
    end
  end

  context "parameters" do
    before do
      @result_container = start_test_container("Test Container")
      @test_case = start_test_case(name: "Test case", full_name: "Full name")
      @test_step = start_test_step(name: "Step name", descrption: "step description")
    end

    it "without parameters" do
      expect(@test_step.parameters).to be_empty
    end

    it "with parameter" do
      lifecycle.update_test_step { |step| step.parameters.push(Allure::Parameter.new("param", 'test')) }
      expect(@test_step.parameters).to include(Allure::Parameter.new("param", 'test'))
    end
  end
end
