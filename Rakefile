# frozen_string_literal: true

require_relative "tasks/release"

desc "Build gem files for all projects"
task build: "all:build"

desc "Release all gems to rubygems"
task release: "all:push"

desc "Run all tests by default"
task default: :test

%w[test rubocop gem].each do |task_name|
  desc "Run #{task_name} for all projects"
  task task_name do
    errors = FRAMEWORKS.each_with_object([]) do |project, a|
      system(%(cd #{project} && #{$PROGRAM_NAME} #{task_name} --trace)) || a << project
    end
    raise Exception.new("Errors in #{errors.join(', ')}") unless errors.empty?
  end
end
