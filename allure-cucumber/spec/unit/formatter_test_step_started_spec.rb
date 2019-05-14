# frozen_string_literal: true

describe "CucumberFormatter.on_test_step_started" do
  include_context "allure mock"
  include_context "cucumber runner"

  let(:result_utils) { Allure::ResultUtils }

  context "test step" do
    before do
      allow(lifecycle).to receive(:prepare_attachment) do |name, type|
        Allure::AllureLifecycle.new.prepare_attachment(name, type)
      end
    end

    it "is started" do
      run_cucumber_cli("features/features/step/simple.feature")

      expect(lifecycle).to have_received(:start_test_step).once do |step|
        aggregate_failures "Should start with correct parameters" do
          expect(step.name).to eq("Given a is 5")
          expect(step.attachments).to be_empty
        end
      end
    end

    it "is started with multiline arg attachment" do
      run_cucumber_cli("features/features/step/table.feature")

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
      run_cucumber_cli("features/features/step/docstring.feature")

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
      run_cucumber_cli("features/features/hooks.feature", "--tags", "@before")

      expect(lifecycle).to have_received(:start_prepare_fixture).once do |fixture|
        expect(fixture.name).to eq("env.rb:12")
      end
    end

    it "for after hook is started" do
      run_cucumber_cli("features/features/hooks.feature", "--tags", "@after")

      expect(lifecycle).to have_received(:start_tear_down_fixture).once do |fixture|
        expect(fixture.name).to eq("env.rb:19")
      end
    end
  end
end
