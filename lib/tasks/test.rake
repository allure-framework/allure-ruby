# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"

require_relative "../task_helpers/util"
require_relative "../task_helpers/simplecov_merger"

class TestTasks
  include Rake::DSL
  include TaskUtil

  def initialize
    add_single_adapter_tasks
    add_all_adapters_tasks
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

  def add_all_adapters_tasks
    desc "Run rubocop for all adapters"
    task(:rubocop) { run_all_adapters(:rubocop) }

    desc "Run tests for all adapters"
    task(:test) { run_all_adapters(:test) }

    desc "Run all tests and generate SimpleCov report"
    task("test:coverage") do
      ENV["COVERAGE"] = "true"
      run_all_adapters(:test)
    ensure
      SimpleCovMerger.merge_coverage
    end
  end

  def add_single_adapter_tasks
    adapters.each do |adapter|
      namespace adapter do
        desc "Run rubocop for #{adapter}"
        task(:rubocop) { run_single_adapter(adapter, :rubocop) }

        desc "Run tests for #{adapter}"
        task(:test, :tag) { |_task, args| run_single_adapter(adapter, "test[#{args[:tag] || ''}]") }
      end
    end
  end

  def run_all_adapters(task_name)
    errors = adapters.each_with_object([]) do |adapter, a|
      puts "Executing #{task_name} for #{adapter}".yellow
      run_single_adapter(adapter, task_name)
    rescue StandardError
      a << adapter
    end

    raise StandardError, "Errors in #{errors.join(', ')}" unless errors.empty?
  end

  def run_single_adapter(adapter, task_name)
    system("cd #{adapter} && #{$PROGRAM_NAME} #{task_name}") || (raise StandardError, "Task failed!")
  end
end
