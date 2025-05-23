# frozen_string_literal: true

describe "AllureLifecycle::TestCaseResult" do
  include_context "lifecycle mocks"

  let!(:result_container) { @result_container = start_test_container("Test Container") }
  let!(:test_case) { start_test_case(name: "Test Case", environment: environment) }
  let(:environment) { "test" }

  context "without allure environment" do
    let(:environment) { nil }

    it "starts test case" do
      aggregate_failures "Should start test and add to test container" do
        expect(test_case.start).to be_a(Numeric)
        expect(test_case.stage).to eq(Allure::Stage::RUNNING)
        expect(result_container.children.last).to eq(test_case.uuid)
      end
    end

    it "updates test case" do
      lifecycle.update_test_case { |test| test.full_name = "Full name: Test" }

      expect(test_case.full_name).to eq("Full name: Test")
    end

    it "stops test" do
      lifecycle.stop_test_case

      aggregate_failures "Should update parameters" do
        expect(test_case.stop).to be_a(Numeric)
        expect(test_case.stage).to eq(Allure::Stage::FINISHED)
      end
    end

    it "calls file writer on stop" do
      lifecycle.stop_test_case

      expect(file_writer).to have_received(:write_test_result).with(test_case)
    end

    it "adds default labels" do
      expect(test_case.labels).to include(
        Allure::Label.new("thread", Thread.current.object_id),
        Allure::Label.new("host", Socket.gethostname),
        Allure::Label.new("language", "ruby")
      )
    end
  end

  context "history id" do
    it "History id is different for different non-excluded parameters" do
      test_case1 = start_test_case(name: "Test Case", history_id: 1)
      lifecycle.update_test_case do |test_case|
        test_case.parameters.push(Allure::Parameter.new("name", "value1"))
      end
      test_case1.stop

      test_case2 = start_test_case(name: "Test Case", history_id: 1)
      lifecycle.update_test_case do |test_case|
        test_case.parameters.push(Allure::Parameter.new("name", "value2"))
      end
      test_case2.stop
      expect(test_case1.history_id).not_to eq(test_case2.history_id)
    end

    it "History id is the same for excluded parameters" do
      test_case1 = start_test_case(name: "Test Case", history_id: 1)
      lifecycle.update_test_case do |test_case|
        test_case.parameters.push(Allure::Parameter.new("name", "value1", excluded: true))
      end
      test_case1.stop

      test_case2 = start_test_case(name: "Test Case", history_id: 1)
      lifecycle.update_test_case do |test_case|
        test_case.parameters.push(Allure::Parameter.new("name", "value2", excluded: true))
      end
      test_case2.stop
      expect(test_case1.history_id).to eq(test_case2.history_id)
    end
  end

  context "with allure environment" do
    let(:environment) { "test" }

    it "starts test case in allure environment" do
      expect(test_case.parameters).to include(Allure::Parameter.new("environment", environment))
    end
  end
end
