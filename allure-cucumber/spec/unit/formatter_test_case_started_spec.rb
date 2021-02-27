# frozen_string_literal: true

describe "on_test_case_started" do
  include_context "allure mock"
  include_context "cucumber runner"

  let(:result_utils) { Allure::ResultUtils }
  let(:feature) { "Simple feature" }
  let(:scenario) { "Add a to b" }
  let(:severity_label) { result_utils.severity_label("normal") }
  let(:behavior_labels) do
    [
      result_utils.epic_label("features"),
      result_utils.feature_label(feature),
      result_utils.story_label(scenario)
    ]
  end
  let(:labels) do
    [
      result_utils.framework_label("cucumber"),
      result_utils.package_label("features"),
      result_utils.test_class_label("test"),
      result_utils.suite_label(feature),
      severity_label,
      *behavior_labels
    ]
  end

  context "default parameters" do
    it "are added to allure test container" do
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

    it "are added to allure test case" do
      run_cucumber_cli(<<~FEATURE)
        Feature: #{feature}

        Scenario: #{scenario}
          Simple scenario description
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        aggregate_failures "Should have correct args" do
          expect(arg.name).to eq(scenario)
          expect(arg.description).to eq("Simple scenario description")
          expect(arg.full_name).to eq(scenario)
          expect(arg.links).to be_empty
          expect(arg.parameters).to be_empty
          expect(arg.history_id).to eq(
            Digest::MD5.hexdigest("#<Cucumber::Core::Test::Case: #{test_tmp_dir}/features/test.feature:3>")
          )
          expect(arg.labels).to match_array(labels)
        end
      end
    end
  end

  context "cucumber tags" do
    it "are parsed correctly" do
      run_cucumber_cli(<<~FEATURE)
        @FeatureTag @ISSUE:BUG-22400 @flaky @TMS:OAT-4444
        Feature: #{feature}

        @good
        Scenario: #{scenario}
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.labels).to match_array(
          [
            result_utils.tag_label("FeatureTag"),
            result_utils.tag_label("good"),
            *labels
          ]
        )
      end
    end
  end

  context "severity tag" do
    let(:severity_label) { result_utils.severity_label("blocker") }
    it "is parsed correctly" do
      run_cucumber_cli(<<~FEATURE)
        Feature: #{feature}

        @SEVERITY:blocker
        Scenario: #{scenario}
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.labels).to match_array(labels)
      end
    end
  end

  context "behavior tags" do
    let(:behavior_labels) do
      [
        result_utils.epic_label("custom-epic"),
        result_utils.feature_label("custom-feature"),
        result_utils.story_label("custom-story")
      ]
    end

    it "are parsed correctly" do
      run_cucumber_cli(<<~FEATURE)
        @EPIC:custom-epic @FEATURE:custom-feature
        Feature: #{feature}

        @STORY:custom-story
        Scenario: #{scenario}
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.labels).to match_array(labels)
      end
    end
  end

  context "tms and issue tags" do
    it "are parsed correctly" do
      run_cucumber_cli(<<~FEATURE)
        Feature: #{feature}

        @ISSUE:BUG-22400 @flaky @TMS:OAT-4444
        Scenario: #{scenario}
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.links).to match_array(
          [
            result_utils.tms_link("OAT-4444"),
            result_utils.issue_link("BUG-22400")
          ]
        )
      end
    end
  end

  context "status detail tags" do
    it "set status details" do
      run_cucumber_cli(<<~FEATURE)
        @flaky
        Feature: #{feature}

        @muted @known
        Scenario: #{scenario}
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        aggregate_failures do
          expect(arg.status_details).to eq(Allure::StatusDetails.new(flaky: true, muted: true, known: true))
          expect(arg.labels).to match_array(labels)
        end
      end
    end
  end

  context "parameters" do
    it "are added for scenario outline" do
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

      aggregate_failures "Should save scenario outlines with correct parameters" do
        examples = []

        expect(lifecycle).to have_received(:start_test_container).twice
        expect(lifecycle).to(have_received(:start_test_case).twice) { |arg| examples.push(arg) }
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
end
