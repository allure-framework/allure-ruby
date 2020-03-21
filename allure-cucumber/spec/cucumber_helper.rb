# frozen_string_literal: true

require "cucumber/cli/main"

class MockKernel
  def exit(status); end
end

class CucumberHelper
  def initialize(tmp_dir)
    @stdout = StringIO.new
    @stderr = StringIO.new
    @kernel = MockKernel.new
    @tmp_dir = tmp_dir
  end

  def execute(feature, args)
    setup(feature)

    Cucumber::Cli::Main.new(
      [feature_file, *default_args, *args],
      nil,
      @stdout,
      @stderr,
      @kernel,
    ).execute!
  ensure
    write_file("#{tmp_dir}/cucumber_output.txt", all_output)
  end

  def all_output
    [@stdout.string, @stderr.string].reject(&:empty?).join("\n")
  end

  private

  attr_reader :tmp_dir

  def setup(feature)
    FileUtils.rm_rf(tmp_dir)

    write_file(feature_file, feature)
    write_file("#{tmp_dir}/features/support/env.rb", env)
    write_file("#{tmp_dir}/features/step_definitions/step_defs.rb", step_defs)
  end

  def write_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "w") { |file| file.write(content) }
  end

  def feature_file
    "#{tmp_dir}/features/test.feature"
  end

  def default_args
    [
      "--no-color",
      "--require", "#{tmp_dir}/features",
      "--format", "pretty",
      "--format", "AllureCucumber::CucumberFormatter", "--out", "#{tmp_dir}/reports/allure-results"
    ]
  end

  def env
    @env ||= File.read("spec/fixture/env.rb")
  end

  def step_defs
    @step_defs ||= File.read("spec/fixture/step_defs.rb")
  end
end
