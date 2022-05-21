# frozen_string_literal: true

require "cucumber/cli/main"

class MockKernel
  def exit(status); end
end

class CucumberHelper
  ENV = <<~RUBY
    require "allure-cucumber"

    Before("@before") do
    end

    Before("@broken_hook") do
      raise Exception.new("Broken hook!")
    end

    After("@after") do
    end

    Around("@around") do |scenario, block|
      block.call
    end

    AfterStep("@after_step") do
    end
  RUBY

  STEPS = <<~RUBY
    Given("a is {int}") do |num|
      @a = num
    end

    Given("a input is") do |table|
      @a = table.symbolic_hashes.first[:value].to_i
    end

    Given("step has a table") do |table|
    end

    Given("step has a docstring") do |string|
    end

    And("b is {int}") do |num|
      @b = num
    end

    And("this step shoud be skipped") do
    end

    When("I add a to b") do
      @c = @a + @b
    end

    Then("result is {int}") do |num|
      expect(@c).to eq(num)
    end

    Then("step fails with simple exception") do
      raise Exception.new("Simple error!")
    end
  RUBY

  def initialize(tmp_dir)
    @stdout = StringIO.new
    @stderr = StringIO.new
    @kernel = MockKernel.new
    @tmp_dir = tmp_dir
  end

  def execute(feature)
    setup(feature)

    Cucumber::Cli::Main.new(
      [feature_file, *args],
      @stdout,
      @stderr,
      @kernel
    ).execute!
  ensure
    write_file("#{tmp_dir}/cucumber_output.txt", all_output)
  end

  private

  attr_reader :tmp_dir

  def all_output
    [@stdout.string, @stderr.string].reject(&:empty?).join("\n")
  end

  def setup(feature)
    FileUtils.rm_rf(tmp_dir)

    write_file(feature_file, feature)
    write_file("#{tmp_dir}/features/support/env.rb", ENV)
    write_file("#{tmp_dir}/features/step_definitions/step_defs.rb", STEPS)
  end

  def write_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def feature_file
    "#{tmp_dir}/features/test.feature"
  end

  def args
    [
      "--no-color",
      "--require", "#{tmp_dir}/features",
      "--format", "pretty",
      "--format", "AllureCucumber::CucumberFormatter", "--out", "#{tmp_dir}/reports/allure-results"
    ]
  end
end
