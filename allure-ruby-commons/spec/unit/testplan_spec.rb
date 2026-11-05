# frozen_string_literal: true

describe Allure::TestPlan, :aggregate_failures do
  let(:test_ids) { ["test case id, aka allure id"] }
  let(:test_names) { ["some unique id or selector that can be used to run particular test case"] }

  before do
    described_class.instance_variable_set(:@tests, nil)
    described_class.instance_variable_set(:@test_ids, nil)
    described_class.instance_variable_set(:@test_names, nil)
    described_class.instance_variable_set(:@muted_tests, nil)
    described_class.instance_variable_set(:@muted_test_ids, nil)

    %i[@test_plan_path @test_plan].each do |var|
      described_class.send(:remove_instance_variable, var) if described_class.instance_variable_defined?(var)
    end
  end

  around do |example|
    ClimateControl.modify(ALLURE_TESTPLAN_PATH: path) { example.run }
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/correct/testplan.json" }

    it "correct testplan.json" do
      expect(described_class.test_ids).to eq(test_ids)
      expect(described_class.test_names).to eq(test_names)
      expect(described_class.muted_test_ids).to be_nil
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/malformed/testplan.json" }

    it "malformed testplan.json", :focus do
      expect(described_class.test_ids).to eq(nil)
      expect(described_class.test_names).to eq(nil)
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan" }

    it "incorrect test plan directory" do
      expect(described_class.test_ids).to eq(nil)
      expect(described_class.test_names).to eq(nil)
    end
  end

  context "with partial entries" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/partial/testplan.json" }

    it "reads muted IDs and ignores absent IDs and selectors" do
      expect(described_class.test_ids).to eq(["id only"])
      expect(described_class.test_names).to eq(["selector only"])
      expect(described_class.muted_test_ids).to eq(["muted-id"])
    end
  end

  context "without a plan" do
    let(:path) { nil }

    it "has no muted IDs" do
      expect(described_class.muted_test_ids).to be_nil
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/correct" }

    it "testplan.json directory" do
      expect(described_class.test_ids).to eq(test_ids)
      expect(described_class.test_names).to eq(test_names)
    end
  end
end
