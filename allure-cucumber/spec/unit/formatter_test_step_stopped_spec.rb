# frozen_string_literal: true

describe "CucumberFormatter.on_test_step_finished" do
  include_context "allure mock"
  include_context "cucumber runner"

  before do
    @step = Allure::ExecutableItem.new
  end

  context "test step" do
    it "with passed status is updated" do
      run_cucumber_cli("features/features/step/simple.feature")

      expect(lifecycle).to have_received(:update_test_step).with(no_args).once do |&arg|
        arg.call(@step)
        aggregate_failures "Should update with correct arguments" do
          expect(@step.stage).to eq(Allure::Stage::FINISHED)
          expect(@step.status).to eq(Allure::Status::PASSED)
        end
      end
    end

    it "with failed status is updated" do
      run_cucumber_cli("features/features/step/exception.feature")
      expect(lifecycle).to have_received(:update_test_step).with(no_args).once do |&arg|
        arg.call(@step)
        expect(@step.status).to eq(Allure::Status::FAILED)
      end
    end

    it "with skipped status is updated" do
      run_cucumber_cli("features/features/step/skipped.feature")

      expect(lifecycle).to have_received(:update_test_step).with(no_args).twice do |&arg|
        arg.call(@step)
      end
      expect(@step.status).to eq(Allure::Status::SKIPPED)
    end

    it "is stopped" do
      run_cucumber_cli("features/features/step/simple.feature")
      expect(lifecycle).to have_received(:stop_test_step).with(no_args).once
    end
  end

  context "fixture" do
    it "is stopped" do
      run_cucumber_cli("features/features/hooks.feature")
      expect(lifecycle).to have_received(:stop_fixture).with(no_args).exactly(3).times
    end

    it "with passed status is updated" do
      run_cucumber_cli("features/features/hooks.feature", "--tags", "@before")

      expect(lifecycle).to have_received(:update_fixture).with(no_args).once do |&arg|
        arg.call(@step)
        expect(@step.status).to eq(Allure::Status::PASSED)
      end
    end

    it "with failed status is updated" do
      run_cucumber_cli("features/features/hooks.feature", "--tags", "@broken_hook")

      expect(lifecycle).to have_received(:update_fixture).with(no_args).once do |&arg|
        arg.call(@step)
        expect(@step.status).to eq(Allure::Status::FAILED)
      end
    end
  end
end
