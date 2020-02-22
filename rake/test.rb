# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"
require "json"
require "fileutils"

require_relative "util"

class CodeClimateUploader
  CC_REPORTER_URL = "https://codeclimate.com/downloads/test-reporter/test-reporter-0.6.3-linux-amd64"
  CC_REPORTER = "vendor/bundle/cc_reporter_0.6.3"
  CC_JSON = "codeclimate.json"
  SIMPLECOV_RESULT = "coverage/.resultset.json"

  class << self
    def upload
      download_reporter
      format_coverage
      upload_coverage
    end

    private

    def format_coverage
      system(cc_env, "./#{CC_REPORTER} format-coverage #{SIMPLECOV_RESULT} -t simplecov -o #{CC_JSON}")
    end

    def upload_coverage
      system(cc_env, "./#{CC_REPORTER} upload-coverage -i #{CC_JSON}")
    end

    def cc_env
      @cc_env ||= {
        "GIT_COMMIT_SHA" => pull_request? ? context.event.pull_request.head.sha : context.sha,
        "GIT_BRANCH" => pull_request? ? ENV["GITHUB_HEAD_REF"] : ENV["GITHUB_REF"].split("/").last,
        "CI_NAME" => "github-actions",
      }
    end

    def context
      @context ||= JSON.parse(ENV["CONTEXT"], object_class: OpenStruct)
    end

    def pull_request?
      @pull_request ||= ENV["GITHUB_EVENT_NAME"] == "pull_request"
    end

    def download_reporter
      return if File.exist?(CC_REPORTER)

      system("curl -s -L #{CC_REPORTER_URL} -o #{CC_REPORTER} && chmod a+x #{CC_REPORTER}")
    end
  end
end

class TestTasks
  include Rake::DSL
  include TaskUtil

  def initialize
    add_single_adaptor_tasks
    add_all_adaptors_tasks
  end

  def self.add_rspec_task
    RSpec::Core::RakeTask.new(:test, :tag) do |task, args|
      args[:tag].tap do |tag|
        task.rspec_opts = "--color --tty --require spec_helper --format documentation #{tag ? "--tag #{tag}" : ''}"
        task.verbose = false
      end
    end
  end

  def self.add_rubocop_task
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.options = %w[--parallel --color]
      task.verbose = false
    end
  end

  private

  def add_all_adaptors_tasks
    namespace :all do
      task(:rubocop) { run_all_adaptors(:rubocop) }
      task(:test) { run_all_adaptors(:test) }
      task(:test_with_coverage) do
        ENV["COVERAGE"] = "true"
        run_all_adaptors(:test)
      ensure
        merge_coverage
      end
    end
  end

  def add_single_adaptor_tasks
    adaptors.each do |adaptor|
      namespace adaptor do
        desc "Run rubocop for #{adaptor}"
        task(:rubocop) { run_single_adaptor(adaptor, :rubocop) }

        desc "Run tests for #{adaptor}"
        task(:test, :tag) { |_task, args| run_single_adaptor(adaptor, "test[#{args[:tag] || ''}]") }
      end
    end
  end

  def run_all_adaptors(task_name)
    errors = adaptors.each_with_object([]) do |adaptor, a|
      puts "Executing #{task_name} for #{adaptor}".yellow
      run_single_adaptor(adaptor, task_name)
    rescue
      a << adaptor
    end
    raise StandardError.new("Errors in #{errors.join(', ')}") unless errors.empty?
  end

  def run_single_adaptor(adaptor, task_name)
    system("cd #{adaptor} && #{$PROGRAM_NAME} #{task_name}") || (raise StandardError.new("Task failed!"))
  end

  def merge_coverage
    ENV["COV_MERGE"] = "true"
    require "simplecov"
    require "simplecov-console"

    SimpleCov.configure do
      %w[allure-cucumber allure-rspec allure-ruby-commons].each { |g| add_group(g, g) }
      formatter(multiformatter)
    end

    merge_results
    CodeClimateUploader.upload if ENV["CI"] && ENV["RUBY_VERSION"] == "2.7"
  end

  def merge_results
    puts "Generating combined coverage report".yellow
    results = Dir.glob("#{root}/*/coverage/.resultset.json").each_with_object([]) do |file, res|
      res << SimpleCov::Result.from_hash(JSON.parse(File.read(file)))
    end
    SimpleCov::ResultMerger.merge_results(*results).tap do |result|
      SimpleCov::ResultMerger.store_result(result)
      result.format!
    end
  end

  def multiformatter
    formatters = [SimpleCov::Formatter::Console]
    formatters << SimpleCov::Formatter::HTMLFormatter if ENV["COV_HTML_REPORT"]
    SimpleCov::Formatter::MultiFormatter.new(formatters)
  end
end

TestTasks.new
