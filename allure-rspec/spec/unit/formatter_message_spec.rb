# frozen_string_literal: true

describe "message" do
  include_context "allure mock"
  include_context "rspec runner"

  let(:passing_example) do
    <<~SPEC
      describe "Suite" do
        it "passes" do
        end
      end
    SPEC
  end

  def run_with_suite_hooks(hooks)
    run_rspec("#{hooks}\n#{passing_example}")
  end

  it "adds a before(:suite) failure to globals" do
    run_with_suite_hooks(<<~SPEC)
      RSpec.configure do |config|
        config.before(:suite) { raise "before suite failed" }
      end
    SPEC

    expect(lifecycle).to have_received(:add_global_error).with(
      message: "An error occurred in a `before(:suite)` hook.",
      trace: a_string_including("RuntimeError", "before suite failed")
    ).once
  end

  it "adds an after(:suite) failure to globals" do
    run_with_suite_hooks(<<~SPEC)
      RSpec.configure do |config|
        config.after(:suite) { raise "after suite failed" }
      end
    SPEC

    expect(lifecycle).to have_received(:add_global_error).with(
      message: "An error occurred in an `after(:suite)` hook.",
      trace: a_string_including("RuntimeError", "after suite failed")
    ).once
  end

  it "adds every failed suite hook" do
    errors = []
    allow(lifecycle).to receive(:add_global_error) { |**details| errors << details }

    run_with_suite_hooks(<<~SPEC)
      RSpec.configure do |config|
        config.after(:suite) { raise "first after suite failed" }
        config.after(:suite) { raise "second after suite failed" }
      end
    SPEC

    expect(errors.map { |error| error[:trace] }).to contain_exactly(
      a_string_including("first after suite failed"),
      a_string_including("second after suite failed")
    )
  end

  it "removes ANSI formatting from a suite-hook failure" do
    error = nil
    allow(lifecycle).to receive(:add_global_error) { |**details| error = details }

    run_rspec(<<~SPEC)
      RSpec.configuration.reporter.message(
        "\e[31mAn error occurred in a `before(:suite)` hook.\e[0m\n" \
        "\e[31mRuntimeError: colored failure\e[0m"
      )

      #{passing_example}
    SPEC

    expect(error).to include(message: "An error occurred in a `before(:suite)` hook.")
    expect(error[:trace]).to include("RuntimeError: colored failure")
    expect(error[:trace]).not_to include("\e[")
  end

  it "ignores an ordinary reporter message" do
    run_rspec(<<~SPEC)
      RSpec.configuration.reporter.message("ordinary reporter message")

      #{passing_example}
    SPEC

    expect(lifecycle).not_to have_received(:add_global_error)
  end

  it "ignores a load error" do
    run_rspec(<<~SPEC)
      raise "spec load failed"
    SPEC

    expect(lifecycle).not_to have_received(:add_global_error)
  end

  it "captures the error before globals are written" do
    run_with_suite_hooks(<<~SPEC)
      RSpec.configure do |config|
        config.after(:suite) { raise "after suite failed" }
      end
    SPEC

    expect(lifecycle).to have_received(:add_global_error).once.ordered
    expect(lifecycle).to have_received(:write_globals).once.ordered
  end
end
