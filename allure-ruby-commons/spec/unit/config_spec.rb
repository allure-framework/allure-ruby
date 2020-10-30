# frozen_string_literal: true

describe Allure::Config do
  let(:test_ids) { ["test case id, aka allure id"] }
  let(:test_names) { ["some unique id or selector that can be used to run particular test case"] }

  around do |example|
    ClimateControl.modify(ALLURE_TESTPLAN_PATH: path) { example.run }
  end

  subject { Class.new(described_class).instance }

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/correct" }

    it "correct testplan.json" do
      aggregate_failures do
        expect(subject.test_ids).to eq(test_ids)
        expect(subject.test_names).to eq(test_names)
      end
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/malformed" }

    it "malformed testplan.json" do
      aggregate_failures do
        expect(subject.test_ids).to eq(nil)
        expect(subject.test_names).to eq(nil)
      end
    end
  end

  context "handles" do
    let(:path) { nil }

    it "missing testplan.json" do
      aggregate_failures do
        expect(subject.test_ids).to eq(nil)
        expect(subject.test_names).to eq(nil)
      end
    end
  end
end
