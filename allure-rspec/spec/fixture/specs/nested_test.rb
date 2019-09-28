# frozen_string_literal: true

describe "Suite" do
  describe "Nested Suite 1" do
    it "Spec 1 - 1" do
    end
  end
  describe "Nested Suite 2" do
    it "Spec 2 - 1" do
    end
    it "Spec 2 - 2" do
    end
    describe "Nested Suite 2:1" do
      it "Spec 2:1 - 1" do
      end
      describe "Nested Suite 2:1:1" do
        it "Spec 2:1:1 - 1"
      end
    end
  end
  it "Spec" do
  end
end
