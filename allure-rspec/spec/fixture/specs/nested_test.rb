# frozen_string_literal: true

describe "Top level suite" do
  describe "Nested Suite 1" do
    it "spec for first nested suite" do
    end
  end
  describe "Nested Suite 2" do
    it "spec for second nested suite 1" do
    end
    it "spec for second nested suite 2" do
    end
    describe "Nested Suite 2:1" do
      it "spec for second level nested suite" do
      end
    end
  end
  it "spec for top level suite" do
  end
end
