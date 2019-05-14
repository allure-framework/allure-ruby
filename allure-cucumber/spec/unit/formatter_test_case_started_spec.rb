# frozen_string_literal: true

describe "CucumberFormatter.on_test_case_started" do
  include_context "allure mock"
  include_context "cucumber runner"

  let(:result_utils) { Allure::ResultUtils }

  it "starts test container with correct arguments" do
    run_cucumber_cli("features/features/simple.feature")

    expect(lifecycle).to have_received(:start_test_container).once do |arg|
      expect(arg.name).to eq("Add a to b")
    end
  end

  it "starts test case with correct arguments" do
    run_cucumber_cli("features/features/simple.feature")

    feature = "Simple feature"
    scenario = "Add a to b"
    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      aggregate_failures "Should have correct args" do
        expect(arg.name).to eq(scenario)
        expect(arg.description).to eq("Simple scenario description")
        expect(arg.full_name).to eq("#{feature}: #{scenario}")
        expect(arg.links).to be_empty
        expect(arg.parameters).to be_empty
        expect(arg.history_id).to eq(
          Digest::MD5.hexdigest("#<Cucumber::Core::Test::Case: features/features/simple.feature:3>"),
        )
        expect(arg.labels).to include(
          result_utils.feature_label(feature),
          result_utils.story_label(scenario),
        )
      end
    end
  end

  it "parses tags correctly" do
    run_cucumber_cli("features/features/tags.feature", "--tags", "not @status_details")

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      aggregate_failures "Should have correct args" do
        expect(arg.links).to contain_exactly(
          result_utils.tms_link("OAT-4444"),
          result_utils.issue_link("BUG-22400"),
        )
        expect(arg.labels).to include(
          result_utils.tag_label("FeatureTag"),
          result_utils.tag_label("good"),
          result_utils.severity_label("blocker"),
        )
      end
    end
  end

  it "sets status details from tags" do
    run_cucumber_cli("features/features/tags.feature", "--tags", "@status_details")

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      aggregate_failures "Should have correct args" do
        expect(arg.status_details).to eq(
          Allure::StatusDetails.new(flaky: true, muted: true, known: true),
        )
      end
    end
  end

  it "handles scenario outlines" do
    run_cucumber_cli("features/features/outline.feature")

    examples = []
    expect(lifecycle).to have_received(:start_test_container).twice
    expect(lifecycle).to have_received(:start_test_case).twice do |arg|
      examples.push(arg)
    end

    aggregate_failures "Should save scenario outlines with correct parameters" do
      expect(examples[0].name).to include("Add a to b, Examples (#1)")
      expect(examples[1].name).to include("Add a to b, Examples (#2)")
      expect(examples[0].parameters).to contain_exactly(
        Allure::Parameter.new("argument", "5"),
        Allure::Parameter.new("argument", "10"),
        Allure::Parameter.new("argument", "15"),
      )
      expect(examples[1].parameters).to contain_exactly(
        Allure::Parameter.new("argument", "6"),
        Allure::Parameter.new("argument", "7"),
        Allure::Parameter.new("argument", "13"),
      )
    end
  end
end
