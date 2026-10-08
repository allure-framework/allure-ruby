# frozen_string_literal: true

describe Allure::Config do
  describe "global_labels" do
    it "defaults to an empty array" do
      expect(described_class.send(:new).global_labels).to eq([])
    end

    it "keeps default arrays independent between configurations" do
      first_config = described_class.send(:new)
      second_config = described_class.send(:new)

      first_config.global_labels << { name: "owner", value: "qa" }

      expect(second_config.global_labels).to eq([])
    end
  end
end
