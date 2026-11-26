# frozen_string_literal: true

describe "on_test_run_finished" do
  include_context "allure mock"
  include_context "cucumber runner"

  it "writes run-level files" do
    run_cucumber_cli(<<~FEATURE)
      Feature: Simple feature

      Scenario: Add a to b
        Simple scenario description
        Given a is 5
    FEATURE

    expect(lifecycle).to have_received(:write_environment).once
    expect(lifecycle).to have_received(:write_globals).once
  end

  context "with excluded tests" do
    let(:excluded_id) { Digest::MD5.hexdigest("#{test_tmp_dir}/features/test.feature#Excluded scenario") }
    let(:excluded_selector) { "#{test_tmp_dir}/features/test.feature#Selector scenario" }

    before do
      allow(Allure::TestPlan).to receive(:excluded_tests?).and_return(true)
      allow(Allure::TestPlan).to receive(:excluded?).and_call_original
      allow(Allure::TestPlan).to receive(:excluded?).with(
        allure_id: "123", selector: anything, test_case_id: anything
      ).and_return(true)
      allow(Allure::TestPlan).to receive(:excluded?).with(
        allure_id: "456", selector: anything, test_case_id: excluded_id
      ).and_return(true)
      allow(Allure::TestPlan).to receive(:excluded?).with(
        allure_id: nil, selector: excluded_selector, test_case_id: anything
      ).and_return(true)
      allow(Allure::AllureLifecycle).to receive(:new).and_call_original
    end

    it "skips scenarios matching an inherited Allure ID, generated identity or selector" do
      allow(AllureCucumber::Scenario).to receive(:new).and_call_original
      excluded_names = ["Allure ID scenario", "Excluded scenario", "Selector scenario"]

      status = run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        @allure_id:123
        Rule: Explicit IDs
          Scenario: Allure ID scenario
            Then step fails with simple exception

        Rule: Generated IDs
          @allure_id:456
          Scenario: Excluded scenario
            Then step fails with simple exception

          Scenario: Selector scenario
            Then step fails with simple exception

          Scenario: Add a to b
            Simple scenario description
            Given a is 5
      FEATURE

      results = Dir["#{test_tmp_dir}/reports/allure-results/*-result.json"].flat_map { |f| JSON.parse(File.read(f)) }
      excluded = results.select { |t| excluded_names.include?(t["name"]) }

      aggregate_failures do
        expect(status).to eq(0)
        expect(results.find { |t| t["name"] == "Add a to b" }["status"]).to eq("passed")
        expect(excluded.size).to eq(3)
        expect(excluded.map { |t| t["status"] }).to all(eq("skipped"))
        expect(excluded.map { |t| t["statusDetails"]["muted"] }).to all(be(true))
        expect(AllureCucumber::Scenario).to have_received(:new).exactly(8).times
      end
    end
  end
end
