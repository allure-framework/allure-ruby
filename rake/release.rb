# frozen_string_literal: true

require_relative "util"

class ReleaseTasks
  include Rake::DSL
  include TaskUtil

  def initialize
    directory "pkg"

    add_adaptor_build_tasks
    add_build_tasks
  end

  private

  def add_adaptor_build_tasks # rubocop:disable Metrics/MethodLength
    adaptors.each do |adaptor|
      namespace adaptor do
        gem = -> { "#{adaptor}-#{version}.gem" }
        gem_path = -> { "#{root}/pkg/#{gem.call}" }
        gemspec = "#{adaptor}.gemspec"

        task(:clean) do
          system("rm -f #{gem_path.call}")
        end

        task(gem: :pkg) do
          puts "Building #{gem.call}".yellow
          sh "cd #{adaptor} && gem build #{gemspec} && mv #{gem.call} #{gem_path.call}"
        end

        task(build: %i[clean gem])

        task(release: :build) do
          puts "Pushing #{gem.call}".yellow
          sh "gem push #{gem_path.call}"
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
