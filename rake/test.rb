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
    %w[test rubocop].each do |task_name|
      desc "Run #{task_name} task for all adaptors"
      task task_name do
        errors = adaptors.each_with_object([]) do |adaptor, a|
          puts "\nExecuting #{task_name} for #{adaptor}".yellow
          run_task(adaptor, task_name) || a << adaptor
        end
        raise Exception.new("Errors in #{errors.join(', ')}") unless errors.empty?
      end
    end
  end

  def add_single_adaptor_tasks
    adaptors.each do |adaptor|
      namespace adaptor do
        desc "Run rubocop for #{adaptor}"
        task(:rubocop) { run_task(adaptor, :rubocop) }

        desc "Run tests for #{adaptor}"
        task(:test, :tag) { |_task, args| run_task(adaptor, "test[#{args[:tag] || ''}]") }
      end
    end
  end

  def run_task(adaptor, task_name)
    system("cd #{adaptor} && #{$PROGRAM_NAME} #{task_name}")
  end
end

TestTasks.new
