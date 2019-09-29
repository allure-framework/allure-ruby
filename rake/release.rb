# frozen_string_literal: true

require_relative "util"

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
    desc "Bump allure version"
    task :bump, [:version] do |_task, args|
      args[:version].tap do |version|
        File.write("#{root}/ALLURE_VERSION", version, mode: "w")

        puts "Updating version to #{version}".yellow
        sh "bundle install --quiet && git commit Gemfile.lock ALLURE_VERSION -m 'Update allure to v#{version}'"
        sh "git tag #{version}"
        puts "Pushing to repo".yellow
        sh "git push origin HEAD --follow-tags"
      end
    end
  end

  def add_adaptor_build_tasks
    adaptors.each do |adaptor|
      namespace adaptor do
        gem = "#{root}/pkg/#{adaptor}-#{version}.gem"
        gemspec = "#{adaptor}.gemspec"

        task(:clean) { rm_f gem }
        task(gem: :pkg) { sh "cd #{adaptor} && gem build #{gemspec} && mv #{adaptor}-#{version}.gem #{root}/pkg/" }
        task(build: %i[clean gem])
        task(release: :build) { sh "gem push #{gem}" }
      end
    end
  end

  def add_build_tasks
    desc "Clean gem files from pkg folder"
    task clean: adaptors.map { |adaptor| "#{adaptor}:clean" }

    desc "Build ruby gems for all adaptors"
    task build: adaptors.map { |adaptor| "#{adaptor}:build" }

    desc "Build and push ruby gems to registry for all adaptors"
    task release: adaptors.map { |adaptor| "#{adaptor}:release" }
  end
end

ReleaseTasks.new
