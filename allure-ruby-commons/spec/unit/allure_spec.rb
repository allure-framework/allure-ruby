# frozen_string_literal: true

describe Allure do
  include_context "lifecycle"

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
      Allure.description("Test description")
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
      Allure.add_attachment(name: "Test attach", source: "Some string", type: Allure::ContentType::TXT)
      aggregate_failures "Should return correct attachment parameters" do
        attachment = @test_case.attachments.last
        expect(attachment.name).to eq("Test attach")
        expect(attachment.type).to eq("text/plain")
        expect(attachment.source).to include(".txt")
      end
    end
  end
end
