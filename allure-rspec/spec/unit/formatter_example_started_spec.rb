# frozen_string_literal: true

describe "RSpecFormatter.example_group_started" do
  include_context "allure mock"
  include_context "rspec runner"

  let(:result_utils) { Allure::ResultUtils }

  it "starts test case with correct default arguments" do
    run_rspec("spec/fixture/specs/simple_test.rb")

    suite = "Suite"
    spec = "spec"
    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      aggregate_failures "Should have correct args" do
        expect(arg.name).to eq(spec)
        expect(arg.description).to eq("Location - ./spec/fixture/specs/simple_test.rb:4")
        expect(arg.full_name).to eq("#{suite} #{spec}")
        expect(arg.links).to be_empty
        expect(arg.parameters).to be_empty
        expect(arg.history_id).to eq(Digest::MD5.hexdigest("./spec/fixture/specs/simple_test.rb[1:1]"))
        expect(arg.labels).to include(
          result_utils.feature_label(suite),
          result_utils.story_label(spec),
          result_utils.framework_label("rspec"),
          result_utils.package_label("spec/fixture/specs"),
          result_utils.test_class_label("simple_test"),
        )
      end
    end
  end

  it "creates issue and tms links" do
    run_rspec("spec/fixture/specs/tag_test.rb")

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.links).to contain_exactly(
        result_utils.tms_link("QA-123"),
        result_utils.issue_link("BUG-123"),
      )
    end
  end

  it "adds test severity" do
    run_rspec("spec/fixture/specs/tag_test.rb")

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.labels).to include(result_utils.severity_label("critical"))
    end
  end

  it "adds custom status details" do
    run_rspec("spec/fixture/specs/tag_test.rb")

    expect(lifecycle).to have_received(:start_test_case).once do |arg|
      expect(arg.status_details).to eq(Allure::StatusDetails.new(flaky: true, muted: true, known: false))
    end
  end
end
