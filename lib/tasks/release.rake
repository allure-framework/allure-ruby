# frozen_string_literal: true

require "rake"

require_relative "../task_helpers/util"

class ReleaseTasks
  include Rake::DSL
  include TaskUtil

  def initialize
    directory "pkg"

    add_adapter_build_tasks
    add_build_tasks
  end

  private

  def add_adapter_build_tasks # rubocop:disable Metrics/MethodLength
    adapters.each do |adapter|
      namespace adapter do
        gem = "#{adapter}-#{version}.gem"
        gem_path = "#{root}/pkg/#{gem}"
        gemspec = "#{adapter}.gemspec"

        task(:clean) do
          system("rm -f #{gem_path}")
        end

        task(gem: :pkg) do
          puts "Building #{gem}".yellow
          sh "cd #{adapter} && gem build #{gemspec} && mv #{gem} #{gem_path}"
        end

        task(build: %i[clean gem])

        task(release: :build) do
          puts "Pushing #{gem}".yellow
          sh "gem push #{gem_path}"
          sh "gem exec rubygems-await #{gem_path}"
        end
      end
    end
  end

  def add_build_tasks
    desc "Clean gem files from pkg folder"
    task clean: adapters.map { |adapter| "#{adapter}:clean" }

    desc "Build ruby gems for all adapters"
    task build: adapters.map { |adapter| "#{adapter}:build" }

    desc "Build and push ruby gems to registry for all adapters"
    task release: adapters.map { |adapter| "#{adapter}:release" }
  end
end

ReleaseTasks.new
