# frozen_string_literal: true

describe "example_started" do
  include_context "allure mock"
  include_context "rspec runner"

  let(:result_utils) { Allure::ResultUtils }
  let(:suite) { "suite" }
  let(:spec) { "spec" }
  let(:link_tms_pattern) { "http://www.jira.com/tms/{}" }
  let(:link_issue_pattern) { "http://www.jira.com/issue/{}" }
  let(:labels) do
    [
      result_utils.suite_label(suite),
      result_utils.framework_label("rspec"),
      result_utils.package_label("#{test_tmp_dir}/spec"),
      result_utils.test_class_label("test_spec"),
      result_utils.severity_label("normal"),
      result_utils.epic_label("#{test_tmp_dir}/spec"),
      result_utils.feature_label(suite)
    ]
  end

  context "default parameters" do
    it "are added to allure test case" do
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
          expect(arg.labels).to match_array(labels)
        end
      end
    end

    context "with shared example" do
      it "correctly detects spec location" do
        run_rspec(<<~SPEC)
          shared_examples "shared" do
            it "#{spec}" do |e|
              e.step(name: "test body")
            end
          end

          describe "#{suite}" do
            it_behaves_like "shared"
          end
        SPEC

        expect(lifecycle).to have_received(:start_test_case).once do |arg|
          aggregate_failures "Should have correct args" do
            expect(arg.description).to eq("Location - #{test_tmp_dir}/spec/test_spec.rb:8")
          end
        end
      end
    end
  end

  context "allure environment" do
    let(:allure_environment) { "test" }

    it "prefixes test name with environment" do
      run_rspec(<<~SPEC)
        describe "#{suite}" do
          it "#{spec}" do
          end
        end
      SPEC

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        aggregate_failures "Should have correct args" do
          expect(arg.parameters).to include(Allure::Parameter.new("environment", allure_environment))
        end
      end
    end
  end

  context "special rspec tags" do
    it "are skipped in test case generic labels" do
      run_rspec(<<~SPEC)
        describe "#{suite}", feature: "feature" do
          it "#{spec}",
          tms_2: "QA-124", issue: "BUG-123", severity: "critical", story: "test" do
          end
        end
      SPEC

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.labels).to_not include(
          result_utils.tag_label("tms_2"),
          result_utils.tag_label("issue"),
          result_utils.tag_label("severity"),
          result_utils.tag_label("feature"),
          result_utils.tag_label("story")
        )
      end
    end
  end

  context "custom rspec tags" do
    it "are added as labels" do
      run_rspec(<<~SPEC)
        describe "#{suite}" do
          it "#{spec}", :rspec_tag1, :flaky, :ignored, rspec_tag2: true, custom_tag: :system do
          end
        end
      SPEC

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.labels).to include(
          result_utils.tag_label("rspec_tag1"),
          result_utils.tag_label("rspec_tag2"),
          result_utils.tag_label("flaky"),
          result_utils.tag_label("system")
        )
        expect(arg.labels).not_to include(result_utils.tag_label("ignored"))
      end
    end
  end

  context "tms and issue rspec tags" do
    it "are added as links" do
      run_rspec(<<~SPEC)
        describe "#{suite}" do
          it(
            "#{spec}",
            tms: "QA-123", tms_2: "QA-124", issue: "BUG-123", issue_2: "BUG-124",
            flaky: true, muted: true, severity: "critical"
          ) do
          end
        end
      SPEC

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.links).to match_array(
          [
            result_utils.tms_link("tms", "QA-123", link_tms_pattern),
            result_utils.tms_link("tms", "QA-124", link_tms_pattern),
            result_utils.issue_link("issue", "BUG-123", link_issue_pattern),
            result_utils.issue_link("issue", "BUG-124", link_issue_pattern)
          ]
        )
      end
    end
  end

  context "severity rspec tag" do
    let(:severity_label) { result_utils.severity_label("critical") }

    it "is added as severity label" do
      run_rspec(<<~SPEC)
        describe "#{suite}" do
          it "#{spec}", severity: "critical" do
          end
        end
      SPEC

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.labels).to include(severity_label)
      end
    end
  end

  context "status detail rspec tags" do
    it "are set as allure status details" do
      run_rspec(<<~SPEC)
        describe "#{suite}" do
          it "#{spec}", flaky: true, muted: true, severity: "critical" do
          end
        end
      SPEC

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.status_details).to eq(Allure::StatusDetails.new(flaky: true, muted: true, known: false))
      end
    end
  end

  context "behavior rspec tags" do
    let(:epic) { "epic label" }
    let(:feature) { "feature label" }
    let(:story) { "story label" }
    let(:behavior_labels) do
      [
        result_utils.epic_label(epic),
        result_utils.feature_label(feature),
        result_utils.story_label(story)
      ]
    end

    it "are added as behavior labels" do
      run_rspec(<<~SPEC)
        describe "#{suite}", epic: "#{epic}" do
          context "context", feature: "#{feature}" do
            it "#{spec}", story: "#{story}" do
            end
          end
        end
      SPEC

      expect(lifecycle).to have_received(:start_test_case).once do |arg|
        expect(arg.labels).to include(*behavior_labels)
      end
    end
  end

  context "rspec describe and context blocks" do
    it "are correctly mapped to suite labels" do
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
end
