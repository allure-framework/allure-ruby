# frozen_string_literal: true

describe "AllureLifecycle::Fixtures" do
  include_context "lifecycle mocks"

  context "without exceptions" do
    before do
      @result_container = start_test_container("Test container")
    end

    it "starts prepare fixture" do
      fixture_result = start_fixture("Prepare fixture", "prepare")

      aggregate_failures "Fixture should be started" do
        expect(fixture_result.start).to be_a(Numeric)
        expect(fixture_result.stage).to eq(Allure::Stage::RUNNING)
        expect(@result_container.befores.last).to eq(fixture_result)
      end
    end

    it "starts teardown fixture" do
      fixture_result = start_fixture("Teardown fixture", "tear_down")

      aggregate_failures "Fixture should be started" do
        expect(fixture_result.start).to be_a(Numeric)
        expect(fixture_result.stage).to eq(Allure::Stage::RUNNING)
        expect(@result_container.afters.last).to eq(fixture_result)
      end
    end

    it "updates fixture" do
      fixture_result = start_fixture("Prepare fixture", "prepare")
      lifecycle.update_fixture { |fixture| fixture.status = Allure::Status::SKIPPED }

      expect(fixture_result.status).to eq(Allure::Status::SKIPPED)
    end

    it "stops fixture" do
      fixture_result = start_fixture("Prepare fixture", "prepare")
      lifecycle.stop_fixture

      aggregate_failures "Should update parameters" do
        expect(fixture_result.stop).to be_a(Numeric)
        expect(fixture_result.stage).to eq(Allure::Stage::FINISHED)
      end
    end
  end

  context "logs error message" do
    it "no running container" do
      start_fixture("Prepare fixture", "prepare")
    end

    it "no running fixture" do
      start_test_container("Test container")

      lifecycle.update_fixture { |t| t.full_name = "Test" }
      lifecycle.stop_fixture
    end
  end
end
