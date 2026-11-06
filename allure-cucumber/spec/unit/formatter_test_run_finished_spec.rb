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

  context "with muted tests" do
    let(:muted_id) { Digest::MD5.hexdigest("#{test_tmp_dir}/features/test.feature#Muted scenario") }

    before do
      allow(Allure::TestPlan).to receive(:muted_tests?).and_return(true)
      allow(Allure::TestPlan).to receive(:muted?).and_call_original
      allow(Allure::TestPlan).to receive(:muted?).with(anything, allure_id: "123").and_return(true)
      allow(Allure::TestPlan).to receive(:muted?).with(muted_id, allure_id: "456").and_return(true)
      allow(Allure::AllureLifecycle).to receive(:new).and_call_original
    end

    it "skips scenarios matching either an inherited Allure ID or a generated identity" do
      allow(AllureCucumber::Scenario).to receive(:new).and_call_original
      muted_names = ["Allure ID scenario", "Muted scenario"]

      status = run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        @allure_id:123
        Rule: Explicit IDs
          Scenario: Allure ID scenario
            Then step fails with simple exception

        Rule: Generated IDs
          @allure_id:456
          Scenario: Muted scenario
            Then step fails with simple exception

          Scenario: Add a to b
            Simple scenario description
            Given a is 5
      FEATURE

      results = Dir["#{test_tmp_dir}/reports/allure-results/*-result.json"].flat_map { |f| JSON.parse(File.read(f)) }
      muted = results.select { |t| muted_names.include?(t["name"]) }

      aggregate_failures do
        expect(status).to eq(0)
        expect(results.find { |t| t["name"] == "Add a to b" }["status"]).to eq("passed")
        expect(muted.size).to eq(2)
        expect(muted.map { |t| t["status"] }).to all(eq("skipped"))
        expect(muted.map { |t| t["statusDetails"]["muted"] }).to all(be(true))
        expect(AllureCucumber::Scenario).to have_received(:new).exactly(6).times
      end
    end
  end
end
