# frozen_string_literal: true

describe Allure, test: true do
  include_context "lifecycle"
  include_context "lifecycle mocks"

  context "lifecycle" do
    it "returns thread specific object" do
      lifecycle = Allure.lifecycle
      thr = Thread.new { @lifecycle = Allure.lifecycle }
      thr.join

      expect(lifecycle).not_to eq(@lifecycle)
    end

    it "sets custom lifecycle object" do
      lifecycle = Allure::AllureLifecycle.new
      Allure.lifecycle = lifecycle

      expect(lifecycle).to eq(Allure.lifecycle)
    end
  end

  context "utilities" do
    before(:each) do
      Allure.lifecycle = lifecycle
      start_test_container("Result Container")
      @test_case = start_test_case(name: "Some scenario", full_name: "feature: Some scenario")
    end

    it "adds epic label" do
      Allure.epic("Test Epic")
      expect(@test_case.labels.last).to eq(Allure::Label.new("epic", "Test Epic"))
    end

    it "adds feature label" do
      Allure.feature("Test Feature")
      expect(@test_case.labels.last).to eq(Allure::Label.new("feature", "Test Feature"))
    end

    it "adds story label" do
      Allure.story("Test Story")
      expect(@test_case.labels.last).to eq(Allure::Label.new("story", "Test Story"))
    end

    it "adds suite label" do
      Allure.suite("Test Suite")
      expect(@test_case.labels.last).to eq(Allure::Label.new("suite", "Test Suite"))
    end

    it "sets test case description" do
      Allure.add_description("Test description")
      expect(@test_case.description).to eq("Test description")
    end

    it "sets test case description_html" do
      Allure.description_html("Test description_html")
      expect(@test_case.description_html).to eq("Test description_html")
    end

    it "adds test parameter" do
      Allure.parameter("name", "value")
      expect(@test_case.parameters.last).to eq(Allure::Parameter.new("name", "value"))
    end

    it "adds tms link" do
      Allure.tms("QA", "http://jira.com/tms/QA-123")
      expect(@test_case.links.last).to eq(Allure::Link.new("tms", "QA", "http://jira.com/tms/QA-123"))
    end

    it "adds issue link" do
      Allure.issue("BUG", "http://jira.com/bug/QA-123")
      expect(@test_case.links.last).to eq(Allure::Link.new("issue", "BUG", "http://jira.com/bug/QA-123"))
    end

    it "adds attachment" do
      { name: "Test attach", source: "Some string", type: Allure::ContentType::TXT }.tap do |args|
        expect(file_writer).to receive(:write_attachment).with(args[:source], kind_of(Allure::Attachment))
        Allure.add_attachment(**args)
      end
    end

    it "adds environment" do
      { PROP_1: "test", PROP_2: "test" }.tap do |env|
        expect(file_writer).to receive(:write_environment).with(env)
        Allure.add_environment(env)
      end
    end

    it "adds custom step" do
      test_step = Allure.step(name: "Custom step", status: Allure::Status::FAILED)
      expect(@test_case.steps.last).to eq(test_step)
    end

    it "runs custom step" do
      Allure.run_step("Custom step") do
        1 + 1
      end
      test_step = @test_case.steps.last
      aggregate_failures "custom step should be handled correctly" do
        expect(test_step.name).to eq("Custom step")
        expect(test_step.status).to eq(Allure::Status::PASSED)
        expect(test_step.stage).to eq(Allure::Stage::FINISHED)
      end
    end

    it "correctly handles custom step failure" do
      Allure.run_step("Custom step") do
        raise StandardError.new("Error")
      end
    rescue
      test_step = @test_case.steps.last
      aggregate_failures "custom step should be handled correctly" do
        expect(test_step.name).to eq("Custom step")
        expect(test_step.status).to eq(Allure::Status::BROKEN)
        expect(test_step.stage).to eq(Allure::Stage::FINISHED)
        expect(test_step.status_details.message).to eq("Error")
      end
    end
  end
end
