# frozen_string_literal: true

require "rake"

require_relative "../task_helpers/util.rb"
require_relative "../task_helpers/release_util.rb"

class ReleaseTasks
  include Rake::DSL
  include TaskUtil

  def initialize
    directory "pkg"

    add_version_bump_task
    add_adaptor_build_tasks
    add_build_tasks
  end

  private

  def add_version_bump_task
    desc "Update allure version"
    task :version, [:increment, :push] do |_task, args|
      VersionUpdater.update(args[:increment], args[:push])
    end
  end

  def add_adaptor_build_tasks # rubocop:disable Metrics/MethodLength
    adaptors.each do |adaptor|
      namespace adaptor do
        gem = "#{adaptor}-#{VersionUpdater.version}.gem"
        gem_path = "#{root}/pkg/#{gem}"
        gemspec = "#{adaptor}.gemspec"

        task(:clean) do
          system("rm -f #{gem_path}")
        end

        task(gem: :pkg) do
          puts "Building #{gem}".yellow
          sh "cd #{adaptor} && gem build #{gemspec} && mv #{gem} #{gem_path}"
        end

        task(build: %i[clean gem])

        task(release: :build) do
          puts "Pushing #{gem}".yellow
          sh "gem push #{gem_path}"
        end
      end
    end
  end

  def add_build_tasks
    namespace :all do
      task clean: adaptors.map { |adaptor| "#{adaptor}:clean" }
      task build: adaptors.map { |adaptor| "#{adaptor}:build" }
      task release: adaptors.map { |adaptor| "#{adaptor}:release" }
    end
  end
end

ReleaseTasks.new
