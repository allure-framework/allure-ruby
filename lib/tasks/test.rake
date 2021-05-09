# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"

require_relative "../task_helpers/util"
require_relative "../task_helpers/simplecov_merger"

class TestTasks
  include Rake::DSL
  include TaskUtil

  def initialize
    add_single_adaptor_tasks
    add_all_adaptors_tasks
  end

  def self.add_rspec_task
    RSpec::Core::RakeTask.new(:test, :tag) do |task, args|
      tag = args[:tag]
      rspec_opts = [
        "--color",
        "--tty",
        "--require spec_helper",
        "--format documentation"
      ]
      rspec_opts << "--format AllureRspecFormatter"
      rspec_opts << "--tag #{tag}" if tag

      task.rspec_opts = rspec_opts.join(" ")
      task.verbose = false
    end
  end

  def self.add_rubocop_task
    RuboCop::RakeTask.new do |task|
      task.options = %w[--parallel --color]
      task.verbose = false
    end
  end

  private

  def add_all_adaptors_tasks
    desc "Run rubocop for all adaptors"
    task(:rubocop) { run_all_adaptors(:rubocop) }

    desc "Run tests for all adaptors"
    task(:test) { run_all_adaptors(:test) }

    desc "Run all tests and generate SimpleCov report"
    task("test:coverage") do
      ENV["COVERAGE"] = "true"
      run_all_adaptors(:test)
    ensure
      SimpleCovMerger.merge_coverage
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
    rescue StandardError
      a << adaptor
    end

    raise StandardError, "Errors in #{errors.join(', ')}" unless errors.empty?
  end

  def run_single_adaptor(adaptor, task_name)
    system("cd #{adaptor} && #{$PROGRAM_NAME} #{task_name}") || (raise StandardError, "Task failed!")
  end
end

TestTasks.new
