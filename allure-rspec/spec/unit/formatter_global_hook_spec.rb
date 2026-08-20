# frozen_string_literal: true

describe "global hooks" do
  include_context "allure mock"
  include_context "rspec runner"

  it "reports a failed before(:suite) hook through a global fixture" do
    run_rspec(<<~SPEC)
      RSpec.configure do |config|
        config.before(:suite) { raise "Before suite failed" }
      end

      describe "Suite" do
        it("spec") { }
      end
    SPEC

    expect(lifecycle).to have_received(:start_prepare_fixture).once
    expect(lifecycle).to have_received(:update_fixture).once do |&update|
      fixture = Allure::FixtureResult.new
      update.call(fixture)

      expect(fixture.status).to eq(Allure::Status::BROKEN)
      expect(fixture.status_details.message).to eq("Before suite failed")
    end
    expect(lifecycle).to have_received(:stop_fixture).once
  end

  it "reports a failed after(:suite) hook through a global fixture" do
    run_rspec(<<~SPEC)
      RSpec.configure do |config|
        config.after(:suite) { raise "After suite failed" }
      end

      describe "Suite" do
        it("spec") { }
      end
    SPEC

    expect(lifecycle).to have_received(:start_tear_down_fixture).once
    expect(lifecycle).to have_received(:update_fixture).once do |&update|
      fixture = Allure::FixtureResult.new
      update.call(fixture)

      expect(fixture.status).to eq(Allure::Status::BROKEN)
      expect(fixture.status_details.message).to eq("After suite failed")
    end
    expect(lifecycle).to have_received(:stop_fixture).once
  end
end
