# frozen_string_literal: true

describe Allure::Config do
  let(:tests) do
    [
      {
        id: "test case id, aka allure id",
        selector: "some unique id or selector that can be used to run particular test case"
      }
    ]
  end

  around do |example|
    ClimateControl.modify(ALLURE_TESTPLAN_PATH: path) { example.run }
  end

  subject { Class.new(described_class).instance }

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/correct" }

    it "correct testplan.json" do
      expect(subject.tests).to eq(tests)
    end
  end

  context "handles" do
    let(:path) { "#{Dir.pwd}/spec/fixtures/test_plan/malformed" }

    it "malformed testplan.json" do
      expect(subject.tests).to eq(nil)
    end
  end

  context "handles" do
    let(:path) { nil }

    it "missing testplan.json" do
      expect(subject.tests).to eq(nil)
    end
  end
end
