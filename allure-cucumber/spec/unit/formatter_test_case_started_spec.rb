# frozen_string_literal: true

describe "on_test_case_started" do
  include_context "allure mock"
  include_context "cucumber runner"

  let(:result_utils) { Allure::ResultUtils }

  it "starts test container with correct arguments" do
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
    FEATURE

    expect(lifecycle).to have_received(:start_test_container).once do |arg|
      expect(arg.name).to eq("Add a to b")
    end
  end

  it "starts test case with correct arguments" do
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
    FEATURE

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
          Digest::MD5.hexdigest("#<Cucumber::Core::Test::Case: #{test_tmp_dir}/features/test.feature:3>")
        )
        expect(arg.labels).to include(
          result_utils.feature_label(feature),
          result_utils.story_label(scenario),
          result_utils.framework_label("cucumber")
        )
      end
    end
  end

  it "parses tags correctly" do
    run_cucumber_cli(<<~FEATURE)
      @FeatureTag @ISSUE:BUG-22400 @flaky @TMS:OAT-4444
      Feature: Test Simple Scenarios

      @good @SEVERITY:blocker
      Scenario: Add a to b
        Given a is 5
    FEATURE

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      aggregate_failures "Should have correct args" do
        expect(arg.links).to contain_exactly(
          result_utils.tms_link("OAT-4444"),
          result_utils.issue_link("BUG-22400")
        )
        expect(arg.labels).to include(
          result_utils.tag_label("FeatureTag"),
          result_utils.tag_label("good"),
          result_utils.severity_label("blocker")
        )
      end
    end
  end

  it "sets status details from tags" do
    run_cucumber_cli(<<~FEATURE)
      @FeatureTag @ISSUE:BUG-22400 @flaky @TMS:OAT-4444
      Feature: Test Simple Scenarios

      @status_details @flaky @muted @known
      Scenario: Add a to b
        Given a is 5
    FEATURE

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.status_details).to eq(Allure::StatusDetails.new(flaky: true, muted: true, known: true))
    end
  end

  it "handles scenario outlines" do
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple scenario outline feature

      Scenario Outline: Add a to b
        Given a is <num_a>
        And b is <num_b>
        When I add a to b
        Then result is <result>
        Examples:
          | num_a | num_b | result |
          | 5     | 10    | 15     |
          | 6     | 7     | 13     |
    FEATURE

    examples = []
    expect(lifecycle).to have_received(:start_test_container).twice
    expect(lifecycle).to have_received(:start_test_case).twice do |arg|
      examples.push(arg)
    end

    aggregate_failures "Should save scenario outlines with correct parameters" do
      expect(examples[0].name).to include("Add a to b, Examples (#1)")
      expect(examples[1].name).to include("Add a to b, Examples (#2)")
      expect(examples[0].parameters).to contain_exactly(
        Allure::Parameter.new("num_a", "5"),
        Allure::Parameter.new("num_b", "10"),
        Allure::Parameter.new("result", "15")
      )
      expect(examples[1].parameters).to contain_exactly(
        Allure::Parameter.new("num_a", "6"),
        Allure::Parameter.new("num_b", "7"),
        Allure::Parameter.new("result", "13")
      )
    end
  end
end
