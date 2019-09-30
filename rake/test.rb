# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"

require_relative "util"

class TestTasks
  include Rake::DSL
  include TaskUtil

  def initialize
    add_single_adaptor_tasks
    add_all_adaptors_tasks
  end

  def self.add_rspec_task
    RSpec::Core::RakeTask.new(:test, :tag) do |t, args|
      args[:tag].tap do |tag|
        t.rspec_opts = "--color --require spec_helper --format documentation #{tag ? "--tag #{tag}" : ''}"
      end
    end
  end

  def self.add_rubocop_task
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.options = %w[--parallel]
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
      puts "\nExecuting #{task_name} for #{adaptor}".yellow
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

    results = Dir.glob("#{root}/*/coverage/.resultset.json").each_with_object([]) do |file, res|
      res << SimpleCov::Result.from_hash(JSON.parse(File.read(file)))
    end
    puts "\nGenerating combined coverage report".yellow
    SimpleCov::ResultMerger.merge_results(*results).format!
  end
end

TestTasks.new
