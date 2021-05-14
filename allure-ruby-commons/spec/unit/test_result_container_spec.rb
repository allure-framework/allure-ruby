# frozen_string_literal: true

describe "AllureLifecycle::TestResultContainer" do
  include_context "lifecycle mocks"

  before do
    @result_container = start_test_container("Test Container")
  end

  it "starts test result container" do
    expect(@result_container.start).to be_a(Numeric)
  end

  it "updates test result container" do
    lifecycle.update_test_container { |container| container.description = "Test description" }

    expect(@result_container.description).to eq("Test description")
  end

  it "stops test result container" do
    lifecycle.stop_test_container

    aggregate_failures do
      expect(@result_container.stop).to be_a(Numeric)
      expect(file_writer).to have_received(:write_test_result_container).with(@result_container)
    end
  end
end
