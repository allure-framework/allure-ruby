# frozen_string_literal: true

describe "on_test_step_started" do
  include_context "allure mock"
  include_context "cucumber runner"

  context "test step" do
    it "is started" do
      run_cucumber_cli(<<~SCENARIO)
        Feature: Simple feature

        Scenario: Add a to b
          Simple scenario description
          Given a is 5
      SCENARIO

      expect(lifecycle).to have_received(:start_test_step).once do |step|
        aggregate_failures "Should start with correct parameters" do
          expect(step.name).to eq("Given a is 5")
          expect(step.attachments).to be_empty
        end
      end
    end

    it "is started with multiline arg attachment" do
      run_cucumber_cli(<<~SCENARIO)
        Feature: Simple feature

        Scenario: Add a to b
          Given step has a table
            | value | value_2 |
            | 1     | 2       |
      SCENARIO

      expect(lifecycle).to have_received(:start_test_step).once do |step|
        attachment = step.attachments.first
        aggregate_failures "Should start with correct parameters" do
          expect(step.name).to eq("Given step has a table")
          expect(attachment.name).to eq("data-table")
          expect(attachment.type).to eq(Allure::ContentType::CSV)
          expect(attachment.source).to include("attachment.csv")
        end
      end
    end

    it "is started with docstring attachment" do
      run_cucumber_cli(<<~SCENARIO)
        Feature: Simple feature

        Scenario: Add a to b
          Given step has a docstring
            """
            I am a docstring
            """
      SCENARIO

      expect(lifecycle).to have_received(:start_test_step).once do |step|
        attachment = step.attachments.first
        aggregate_failures "Should start with correct parameters" do
          expect(step.name).to eq("Given step has a docstring")
          expect(attachment.name).to eq("docstring")
          expect(attachment.type).to eq(Allure::ContentType::TXT)
          expect(attachment.source).to include("attachment.txt")
        end
      end
    end
  end

  context "fixture" do
    it "for before hook is started" do
      run_cucumber_cli(<<~SCENARIO, "--tags", "@before")
        Feature: Simple feature

        @before
        Scenario: Add a to b
          Simple scenario description
          Given a is 5
      SCENARIO

      expect(lifecycle).to have_received(:start_prepare_fixture).once do |fixture|
        expect(fixture.name).to eq("env.rb:12")
      end
    end

    it "for after hook is started" do
      run_cucumber_cli(<<~SCENARIO, "--tags", "@after")
        Feature: Simple feature

        @after
        Scenario: Add a to b
          Simple scenario description
          Given a is 5
      SCENARIO

      expect(lifecycle).to have_received(:start_tear_down_fixture).once do |fixture|
        expect(fixture.name).to eq("env.rb:19")
      end
    end
  end
end
