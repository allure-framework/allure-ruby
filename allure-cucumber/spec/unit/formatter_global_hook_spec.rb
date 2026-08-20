# frozen_string_literal: true

describe "global hooks" do
  include_context "allure mock"
  include_context "cucumber runner"

  let(:feature) do
    <<~FEATURE
      Feature: Simple feature

      Scenario: Add a to b
        Given a is 5
    FEATURE
  end

  it "reports a failed BeforeAll hook through a global fixture" do
    stub_const("CucumberHelper::ENV", <<~RUBY)
      #{CucumberHelper::ENV}
      BeforeAll { raise "BeforeAll failed" }
    RUBY

    run_cucumber_cli(feature)

    expect(lifecycle).to have_received(:start_prepare_fixture).once
    expect_failed_fixture("BeforeAll failed")
    expect(lifecycle).to have_received(:stop_fixture).once
  end

  it "reports a failed AfterAll hook through a global fixture" do
    stub_const("CucumberHelper::ENV", <<~RUBY)
      #{CucumberHelper::ENV}
      AfterAll { raise "AfterAll failed" }
    RUBY

    run_cucumber_cli(feature)

    expect(lifecycle).to have_received(:start_tear_down_fixture).once
    expect_failed_fixture("AfterAll failed")
    expect(lifecycle).to have_received(:stop_fixture).once
  end

  def expect_failed_fixture(message)
    expect(lifecycle).to have_received(:update_fixture).once do |&update|
      fixture = Allure::FixtureResult.new
      update.call(fixture)

      expect(fixture.status).to eq(Allure::Status::BROKEN)
      expect(fixture.status_details.message).to eq(message)
    end
  end
end
