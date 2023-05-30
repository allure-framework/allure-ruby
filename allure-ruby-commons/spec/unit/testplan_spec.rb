# frozen_string_literal: true

describe Allure::TestPlan, :aggregate_failures do
  let(:test_ids) { ["test case id, aka allure id"] }
  let(:test_names) { ["some unique id or selector that can be used to run particular test case"] }

  before do
    described_class.instance_variable_set(:@tests, nil)
    described_class.instance_variable_set(:@test_ids, nil)
    described_class.instance_variable_set(:@test_names, nil)

    :@test_plan_path.tap do |var|
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
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/malformed/testplan.json" }

    it "malformed testplan.json" do
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

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/correct" }

    it "testplan.json directory" do
      expect(described_class.test_ids).to eq(test_ids)
      expect(described_class.test_names).to eq(test_names)
    end
  end
end
