# frozen_string_literal: true

describe "example_started" do
  include_context "allure mock"
  include_context "rspec runner"

  let(:result_utils) { Allure::ResultUtils }
  let(:suite) { "suite" }
  let(:spec) { "spec" }
  let(:normal_label) { result_utils.severity_label("normal") }
  let(:default_labels) do
    [
      result_utils.feature_label(suite),
      result_utils.suite_label(suite),
      result_utils.story_label(spec),
      result_utils.framework_label("rspec"),
      result_utils.package_label("#{test_tmp_dir}/spec"),
      result_utils.test_class_label("test_spec")
    ]
  end

  it "starts test case with correct default arguments" do
    run_rspec(<<~SPEC)
      describe "#{suite}" do
        before(:each) do |e|
          e.step(name: "Before hook")
        end

        after(:each) do |e|
          e.step(name: "After hook")
        end

        it "#{spec}" do |e|
          e.step(name: "test body")
        end
      end
    SPEC

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      aggregate_failures "Should have correct args" do
        expect(arg.name).to eq(spec)
        expect(arg.description).to eq("Location - #{test_tmp_dir}/spec/test_spec.rb:10")
        expect(arg.full_name).to eq("#{suite} #{spec}")
        expect(arg.links).to be_empty
        expect(arg.parameters).to be_empty
        expect(arg.history_id).to eq(Digest::MD5.hexdigest("./#{test_tmp_dir}/spec/test_spec.rb[1:1]"))
        expect(arg.labels).to match_array([*default_labels, normal_label])
      end
    end
  end

  it "skips special tags" do
    run_rspec(<<~SPEC)
      describe "#{suite}" do
        it "#{spec}", tms_2: "QA-124", issue: "BUG-123", severity: "critical" do
        end
      end
    SPEC

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.labels).to match_array([*default_labels, result_utils.severity_label("critical")])
    end
  end

  it "adds custom tags" do
    run_rspec(<<~SPEC)
      describe "#{suite}" do
        it "#{spec}", :rspec_tag1, rspec_tag2: true do
        end
      end
    SPEC

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.labels).to match_array(
        [
          *default_labels,
          normal_label,
          result_utils.tag_label("rspec_tag1"),
          result_utils.tag_label("rspec_tag2")
        ]
      )
    end
  end

  it "creates issue and tms links" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it(
          "spec",
          tms: "QA-123", tms_2: "QA-124", issue: "BUG-123", issue_2: "BUG-124",
          flaky: true, muted: true, severity: "critical"
        ) do
        end
      end
    SPEC

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.links).to match_array(
        [
          result_utils.tms_link("QA-123"),
          result_utils.tms_link("QA-124"),
          result_utils.issue_link("BUG-123"),
          result_utils.issue_link("BUG-124")
        ]
      )
    end
  end

  it "adds test severity" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it(
          "spec",
          tms: "QA-123", tms_2: "QA-124", issue: "BUG-123", issue_2: "BUG-124",
          flaky: true, muted: true, severity: "critical"
        ) do
        end
      end
    SPEC

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.labels).to include(result_utils.severity_label("critical"))
    end
  end

  it "adds custom status details" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it(
          "spec",
          tms: "QA-123", tms_2: "QA-124", issue: "BUG-123", issue_2: "BUG-124",
          flaky: true, muted: true, severity: "critical"
        ) do
        end
      end
    SPEC

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.status_details).to eq(Allure::StatusDetails.new(flaky: true, muted: true, known: false))
    end
  end

  it "adds suite labels", test: true do
    run_rspec(<<~SPEC)
      describe "Suite" do
        describe "Nested Suite 1" do
          it "Spec 1 - 1" do
          end
        end
        describe "Nested Suite 2" do
          it "Spec 2 - 1" do
          end
          it "Spec 2 - 2" do
          end
          describe "Nested Suite 2:1" do
            it "Spec 2:1 - 1" do
            end
            describe "Nested Suite 2:1:1" do
              it "Spec 2:1:1 - 1"
            end
          end
        end
        it "Spec" do
        end
      end
    SPEC

    examples = []
    expect(lifecycle).to have_received(:start_test_case).exactly(6).times do |arg|
      examples << arg
    end

    aggregate_failures "Examples should contain correct suite labels" do
      expect(examples.first.labels).to include(Allure::ResultUtils.suite_label("Suite"))
      expect(examples[1].labels).to include(
        Allure::ResultUtils.suite_label("Nested Suite 1"),
        Allure::ResultUtils.parent_suite_label("Suite")
      )
      expect(examples.last.labels).to include(
        Allure::ResultUtils.suite_label("Nested Suite 2"),
        Allure::ResultUtils.parent_suite_label("Suite"),
        Allure::ResultUtils.sub_suite_label("Nested Suite 2:1:1 > Nested Suite 2:1")
      )
    end
  end
end
