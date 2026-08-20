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

    it "keeps a failed fixture on its test container" do
      fixture = start_fixture("Prepare fixture", "prepare")
      lifecycle.update_fixture do |result|
        result.status = Allure::Status::BROKEN
        result.status_details.message = "Fixture failed"
      end
      lifecycle.stop_fixture

      aggregate_failures do
        expect(@result_container.befores).to contain_exactly(fixture)
        expect(file_writer).not_to have_received(:write_globals)
      end
    end
  end

  context "without a running test container" do
    it "writes a failed prepare fixture as a global error" do
      fixture = start_fixture("Global prepare fixture", "prepare")
      details = Allure::StatusDetails.new(
        known: true,
        muted: true,
        flaky: true,
        message: "Global fixture failed",
        trace: "trace line"
      )
      lifecycle.update_fixture do |result|
        result.status = Allure::Status::FAILED
        result.status_details = details
      end
      lifecycle.stop_fixture

      aggregate_failures do
        expect(fixture.stage).to eq(Allure::Stage::FINISHED)
        expect(file_writer).to have_received(:write_globals).with(kind_of(Allure::Globals)) do |globals|
          error = globals.errors.first

          expect(globals.attachments).to be_empty
          expect(error.known).to be(true)
          expect(error.muted).to be(true)
          expect(error.flaky).to be(true)
          expect(error.message).to eq("Global fixture failed")
          expect(error.trace).to eq("trace line")
        end
      end
    end

    it "does not write a passed prepare fixture as a global error" do
      start_fixture("Global prepare fixture", "prepare")
      lifecycle.update_fixture { |fixture| fixture.status = Allure::Status::PASSED }
      lifecycle.stop_fixture

      expect(file_writer).not_to have_received(:write_globals)
    end

    it "does not write an error without failure details" do
      start_fixture("Global prepare fixture", "prepare")
      lifecycle.stop_fixture

      expect(file_writer).not_to have_received(:write_globals)
    end
  end

  context "logs error message" do
    it "no running fixture" do
      start_test_container("Test container")

      lifecycle.update_fixture { |t| t.full_name = "Test" }
      lifecycle.stop_fixture
    end
  end
end
