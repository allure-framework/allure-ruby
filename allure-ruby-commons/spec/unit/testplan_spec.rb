# frozen_string_literal: true

describe Allure::TestPlan, :aggregate_failures do
  subject(:test_plan) { Class.new(described_class) }

  let(:test_ids) { ["test case id, aka allure id"] }
  let(:test_names) { ["some unique id or selector that can be used to run particular test case"] }

  around do |example|
    ClimateControl.modify(ALLURE_TESTPLAN_PATH: path) { example.run }
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/correct/testplan.json" }

    it "correct testplan.json" do
      expect(test_plan.test_ids).to eq(test_ids)
      expect(test_plan.test_names).to eq(test_names)
      expect(test_plan.muted?(allure_id: nil, selector: nil, test_case_id: "muted-id")).to be(false)
      expect(test_plan.muted_tests?).to be(false)
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/malformed/testplan.json" }

    it "malformed testplan.json", :focus do
      expect(test_plan.test_ids).to eq(nil)
      expect(test_plan.test_names).to eq(nil)
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan" }

    it "incorrect test plan directory" do
      expect(test_plan.test_ids).to eq(nil)
      expect(test_plan.test_names).to eq(nil)
    end
  end

  context "with partial entries" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/partial/testplan.json" }

    it "matches muted identities and ignores absent IDs and selectors" do
      matched = test_plan.muted?(allure_id: nil, selector: nil, test_case_id: "muted-id")
      unmatched = test_plan.muted?(allure_id: nil, selector: nil, test_case_id: "other-id")
      missing = test_plan.muted?(allure_id: nil, selector: nil, test_case_id: nil)
      matched_by_allure_id = test_plan.muted?(allure_id: "123", selector: nil, test_case_id: "other-id")
      fallback = test_plan.muted?(allure_id: 456, selector: nil, test_case_id: "muted-id")
      unmatched_ids = test_plan.muted?(allure_id: 456, selector: nil, test_case_id: "other-id")

      expect(test_plan.test_ids).to eq(["id only"])
      expect(test_plan.test_names).to eq(["selector only"])
      expect(matched).to be(true)
      expect(unmatched).to be(false)
      expect(missing).to be(false)
      expect(matched_by_allure_id).to be(true)
      expect(fallback).to be(true)
      expect(unmatched_ids).to be(false)
      expect(test_plan.muted_tests?).to be(true)
    end
  end

  context "with only muted Allure IDs" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/ids_only/testplan.json" }

    it "activates muting without generated identities" do
      available = test_plan.muted_tests?
      matched = test_plan.muted?(allure_id: 123, selector: nil, test_case_id: "other-id")

      expect(available).to be(true)
      expect(matched).to be(true)
    end
  end

  context "with only muted selectors" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/selectors_only/testplan.json" }

    it "activates muting and matches exact full names when IDs do not match" do
      available = test_plan.muted_tests?
      matched = test_plan.muted?(
        allure_id: 456, selector: "spec/test_spec.rb#Suite [case]", test_case_id: "other-id"
      )
      other_file = test_plan.muted?(
        allure_id: nil, selector: "spec/other_spec.rb#Suite [case]", test_case_id: "other-id"
      )
      regex_like = test_plan.muted?(
        allure_id: nil, selector: "spec/test_spec.rb#Suite c", test_case_id: "other-id"
      )

      expect(available).to be(true)
      expect(matched).to be(true)
      expect(other_file).to be(false)
      expect(regex_like).to be(false)
    end
  end

  context "without a plan" do
    let(:path) { nil }

    it "does not mute tests" do
      muted = test_plan.muted?(allure_id: nil, selector: nil, test_case_id: "muted-id")

      expect(muted).to be(false)
      expect(test_plan.muted_tests?).to be(false)
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/correct" }

    it "testplan.json directory" do
      expect(test_plan.test_ids).to eq(test_ids)
      expect(test_plan.test_names).to eq(test_names)
    end
  end
end
