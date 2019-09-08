# frozen_string_literal: true

root = File.expand_path("..", __dir__)
version = File.read("#{root}/ALLURE_VERSION").strip

directory "pkg"

desc "Bump allure version"
task :bump, [:version] do |_task, args|
  version = args[:version]
  File.write("#{root}/ALLURE_VERSION", version, mode: "w")

  sh "bundle install --quiet && git commit Gemfile.lock ALLURE_VERSION -m 'Update allure to v#{version}'"
  sh "git tag #{version}"
  sh "git push origin HEAD --follow-tags"
end

ADAPTORS.each do |adaptor|
  namespace adaptor do
    gem = "pkg/#{adaptor}-#{version}.gem"
    gemspec = "#{adaptor}.gemspec"

    task :clean do
      rm_f gem
    end

    task gem: "pkg" do
      sh "cd #{adaptor} && gem build #{gemspec} && mv #{adaptor}-#{version}.gem #{root}/pkg/"
    end

    task build: %i[clean gem]

    task push: :build do
      sh "gem push #{gem}"
    end
  end
end

namespace :all do
  task build: ADAPTORS.map { |adaptor| "#{adaptor}:build" }
  task install: ADAPTORS.map { |adaptor| "#{adaptor}:install" }
  task push: ADAPTORS.map { |adaptor| "#{adaptor}:push" }
end
