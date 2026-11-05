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
      allow(Allure::TestPlan).to receive(:muted?).with(muted_id).and_return(true)
      allow(Allure::AllureLifecycle).to receive(:new).and_call_original
    end

    it "skips a scenario whose test case id is muted" do
      allow(AllureCucumber::Scenario).to receive(:new).and_call_original

      status = run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        Scenario: Muted scenario
          Then step fails with simple exception

        Scenario: Add a to b
          Simple scenario description
          Given a is 5
      FEATURE

      results = Dir["#{test_tmp_dir}/reports/allure-results/*-result.json"].flat_map { |f| JSON.parse(File.read(f)) }

      aggregate_failures do
        expect(status).to eq(0)
        expect(results.find { |t| t["name"] == "Add a to b" }["status"]).to eq("passed")
        muted = results.find { |t| t["name"] == "Muted scenario" }
        expect(muted["status"]).to eq("skipped")
        expect(muted["statusDetails"]["muted"]).to be(true)
        expect(AllureCucumber::Scenario).to have_received(:new).exactly(4).times
      end
    end
  end
end
