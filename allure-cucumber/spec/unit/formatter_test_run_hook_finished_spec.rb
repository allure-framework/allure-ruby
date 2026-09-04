# frozen_string_literal: true

describe "on_test_run_hook_finished" do
  include_context "allure mock"
  include_context "cucumber runner"

  let(:feature) do
    <<~FEATURE
      Feature: Global hooks

      Scenario: passing scenario
        Given a is 5
    FEATURE
  end

  def run_with_global_hooks(hooks)
    run_cucumber_cli(feature, support_code: "#{CucumberHelper::ENV}\n#{hooks}")
  end

  it "adds a failed BeforeAll hook to globals" do
    run_with_global_hooks(<<~RUBY)
      BeforeAll do
        raise "BeforeAll failed"
      end
    RUBY

    expect(lifecycle).to have_received(:add_global_error).with(
      message: "BeforeAll failed",
      trace: a_string_including("env.rb")
    ).once
  end

  it "adds a failed AfterAll hook to globals" do
    run_with_global_hooks(<<~RUBY)
      AfterAll do
        raise "AfterAll failed"
      end
    RUBY

    expect(lifecycle).to have_received(:add_global_error).with(
      message: "AfterAll failed",
      trace: a_string_including("env.rb")
    ).once
  end

  it "ignores passed global hooks" do
    run_with_global_hooks(<<~RUBY)
      BeforeAll do
      end

      AfterAll do
      end
    RUBY

    expect(lifecycle).not_to have_received(:add_global_error)
  end

  it "adds every failed global hook" do
    errors = []
    allow(lifecycle).to receive(:add_global_error) { |**details| errors << details }

    run_with_global_hooks(<<~RUBY)
      BeforeAll do
        raise "BeforeAll failed"
      end

      AfterAll do
        raise "First AfterAll failed"
      end

      AfterAll do
        raise "Second AfterAll failed"
      end
    RUBY

    expect(errors.map { |error| error[:message] }).to eq(
      ["BeforeAll failed", "First AfterAll failed", "Second AfterAll failed"]
    )
  end

  it "captures the error before globals are written" do
    run_with_global_hooks(<<~RUBY)
      AfterAll do
        raise "AfterAll failed"
      end
    RUBY

    expect(lifecycle).to have_received(:add_global_error).once.ordered
    expect(lifecycle).to have_received(:write_globals).once.ordered
  end
end
