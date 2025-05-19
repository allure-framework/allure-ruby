# frozen_string_literal: true

describe Allure do
  include_context "lifecycle mocks"

  let(:allure_mock) do
    Class.new do
      include Allure
    end
  end

  let(:allure) { allure_mock.new }

  before do
    Thread.current[:test_lifecycle] = lifecycle
    allure.instance_eval(<<~EVAL, __FILE__, __LINE__ + 1)
      def lifecycle
        Thread.current[:test_lifecycle]
      end
    EVAL

    start_test_container("Result Container")
    @test_case = start_test_case(name: "Some scenario", full_name: "feature: Some scenario")
  end

  context "with config helpers" do
    it "yields allure configuration" do
      expect { |b| allure.configure(&b) }.to yield_with_args(Allure::Config.instance)
    end
  end

  context "with label helpers" do
    let(:labels) { @test_case.labels }
    let(:label) { labels.last }

    it "adds single epic label" do
      allure.epic("Test Epic 1")
      allure.epic("Test Epic")

      aggregate_failures do
        expect(label).to eq(Allure::Label.new("epic", "Test Epic"))
        expect(labels.count { |it| it.name == "epic" }).to eq(1)
      end
    end

    it "adds single feature label" do
      allure.feature("Test Feature 1")
      allure.feature("Test Feature")

      aggregate_failures do
        expect(label).to eq(Allure::Label.new("feature", "Test Feature"))
        expect(labels.count { |it| it.name == "feature" }).to eq(1)
      end
    end

    it "adds single story label" do
      allure.story("Test Story 1")
      allure.story("Test Story")

      aggregate_failures do
        expect(label).to eq(Allure::Label.new("story", "Test Story"))
        expect(labels.count { |it| it.name == "story" }).to eq(1)
      end
    end

    it "adds single suite label" do
      allure.suite("Test Suite 1")
      allure.suite("Test Suite")

      aggregate_failures do
        expect(label).to eq(Allure::Label.new("suite", "Test Suite"))
        expect(labels.count { |it| it.name == "suite" }).to eq(1)
      end
    end

    it "adds tag label" do
      allure.tag("Test Tag")
      expect(label).to eq(Allure::Label.new("tag", "Test Tag"))
    end
  end

  context "with description helpers" do
    it "sets test case description" do
      allure.add_description("Test description")
      expect(@test_case.description).to eq("Test description")
    end

    it "sets test case description_html" do
      allure.description_html("Test description_html")
      expect(@test_case.description_html).to eq("Test description_html")
    end
  end

  context "with parameter helpers" do
    it "adds test parameter" do
      allure.parameter("name", "value", excluded: true, mode: "masked")
      expect(@test_case.parameters.last).to eq(Allure::Parameter.new("name", "value", excluded: true, mode: "masked"))
    end
  end

  context "with link helpers" do
    it "adds tms link" do
      allure.tms("QA", "http://jira.com/tms/QA-123")
      expect(@test_case.links.last).to eq(Allure::Link.new("tms", "QA", "http://jira.com/tms/QA-123"))
    end

    it "adds issue link" do
      allure.issue("BUG", "http://jira.com/bug/QA-123")
      expect(@test_case.links.last).to eq(Allure::Link.new("issue", "BUG", "http://jira.com/bug/QA-123"))
    end
  end

  context "with file creation helpers" do
    it "adds attachment" do
      args = { name: "Test attach", source: "Some string", type: Allure::ContentType::TXT }
      allure.add_attachment(**args)

      expect(file_writer).to have_received(:write_attachment).with(args[:source], kind_of(Allure::Attachment))
    end

    it "adds environment" do
      env = { PROP1: "test", PROP2: "test" }
      allure.add_environment(env)

      expect(file_writer).to have_received(:write_environment).with(env)
    end

    it "adds categories" do
      categories = [Allure::Category.new(name: "Ignored test", matched_statuses: [Allure::Status::SKIPPED])]
      allure.add_categories(categories)

      expect(file_writer).to have_received(:write_categories).with(categories)
    end
  end

  context "with step helpers" do
    let(:last_step) { @test_case.steps.last }

    it "adds custom step" do
      test_step = allure.step(name: "Custom step", status: Allure::Status::FAILED)
      expect(last_step).to eq(test_step)
    end

    it "runs custom step" do
      result = allure.run_step("Custom step") do
        1 + 1
      end

      aggregate_failures "custom step should be handled correctly" do
        expect(result).to eq(2)
        expect(last_step.name).to eq("Custom step")
        expect(last_step.status).to eq(Allure::Status::PASSED)
        expect(last_step.stage).to eq(Allure::Stage::FINISHED)
      end
    end

    it "correctly handles custom step failure" do
      expect { allure.run_step("Custom step") { raise(StandardError, "Error") } }.to raise_error("Error")

      aggregate_failures "custom step should be handled correctly" do
        expect(last_step.name).to eq("Custom step")
        expect(last_step.status).to eq(Allure::Status::BROKEN)
        expect(last_step.stage).to eq(Allure::Stage::FINISHED)
        expect(last_step.status_details.message).to eq("Error")
      end
    end

    it "adds parameter" do
      allure.run_step("New step") do
        allure.step_parameter("name", "value", excluded: true, mode: "hidden")
      end
      expect(last_step.parameters.last).to eq(Allure::Parameter.new("name", "value", excluded: true, mode: "hidden"))
    end

    it "invalid parameter mode" do
      msg = "Parameter mode 'jibberish' is invalid. Valid modes are: #{Allure::Parameter::MODES.join(', ')}"
      expect(Allure.configuration.logger).to receive(:error).with(msg)
      allure.run_step("New step") do
        allure.step_parameter("name", "value", excluded: true, mode: "jibberish")
      end
    end
  end

  context "with status details helpers" do
    it "sets testcase flaky status detail" do
      allure.set_flaky
      expect(@test_case.status_details.flaky).to eq(true)
    end

    it "sets testcase muted status detail" do
      allure.set_muted
      expect(@test_case.status_details.muted).to eq(true)
    end

    it "sets testcase known status detail" do
      allure.set_known
      expect(@test_case.status_details.known).to eq(true)
    end
  end
end
