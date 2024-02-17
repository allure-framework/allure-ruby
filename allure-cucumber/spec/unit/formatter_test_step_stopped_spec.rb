# frozen_string_literal: true

describe "on_test_step_finished" do
  include_context "allure mock"
  include_context "cucumber runner"

  before do
    @step = Allure::ExecutableItem.new
  end

  context "test step" do
    it "with passed status is updated" do
      run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        Scenario: Add a to b
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:update_test_step).with(no_args).once do |&arg|
        arg.call(@step)
        aggregate_failures "Should update with correct arguments" do
          expect(@step.stage).to eq(Allure::Stage::FINISHED)
          expect(@step.status).to eq(Allure::Status::PASSED)
        end
      end
    end

    it "with failed status is updated" do
      run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        Scenario: Add a to b
          Then step fails with simple exception
      FEATURE

      expect(lifecycle).to have_received(:update_test_step).with(no_args).once do |&arg|
        arg.call(@step)
      end
      expect(@step.status).to eq(Allure::Status::BROKEN)
    end

    it "with skipped status is updated" do
      run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        Scenario: Add a to b
          Then step fails with simple exception
          And this step shoud be skipped
      FEATURE

      expect(lifecycle).to have_received(:update_test_step).with(no_args).twice do |&arg|
        arg.call(@step)
      end
      expect(@step.status).to eq(Allure::Status::SKIPPED)
    end

    it "is stopped" do
      run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        Scenario: Add a to b
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:stop_test_step).with(no_args).once
    end

    it "for afterstep hook is stopped" do
      run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        @after_step
        Scenario: Add a to b
          Simple scenario description
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:stop_test_step).twice
    end
  end

  context "fixture" do
    it "is stopped" do
      run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        @before @after
        Scenario: Add a to b
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:stop_fixture).with(no_args).exactly(2).times
    end

    it "with passed status is updated" do
      run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        @before
        Scenario: Add a to b
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:update_fixture).with(no_args).once do |&arg|
        arg.call(@step)
        expect(@step.status).to eq(Allure::Status::PASSED)
      end
    end

    it "with failed status is updated" do
      run_cucumber_cli(<<~FEATURE)
        Feature: Simple feature

        @broken_hook
        Scenario: Add a to b
          Given a is 5
      FEATURE

      expect(lifecycle).to have_received(:update_fixture).with(no_args).once do |&arg|
        arg.call(@step)
        expect(@step.status).to eq(Allure::Status::BROKEN)
      end
    end
  end
end
