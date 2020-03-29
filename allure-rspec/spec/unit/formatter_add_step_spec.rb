# frozen_string_literal: true

describe "run_step" do
  include_context "allure mock"
  include_context "rspec runner"

  it "runs step from example" do
    run_rspec(<<~SPEC)
      describe "Suite" do
        it "spec" do |example|
          example.run_step("custom step") do
          end
        end
      end
    SPEC

    aggregate_failures "Runs step" do
      expect(lifecycle).to have_received(:start_test_step).once do |arg|
        expect(arg.name).to eq("custom step")
      end
      expect(lifecycle).to have_received(:update_test_step).once
      expect(lifecycle).to have_received(:stop_test_step).once
    end
  end
end
