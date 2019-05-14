# frozen_string_literal: true

FRAMEWORKS = %w[allure-ruby-commons allure-cucumber].freeze

root = File.expand_path("..", __dir__)
version = File.read("#{root}/ALLURE_VERSION").strip

directory "pkg"

FRAMEWORKS.each do |framework|
  namespace framework do
    gem = "pkg/#{framework}-#{version}.gem"
    gemspec = "#{framework}.gemspec"

    task :clean do
      rm_f gem
    end

    task gem: "pkg" do
      sh "cd #{framework} && gem build #{gemspec} && mv #{framework}-#{version}.gem #{root}/pkg/"
    end

    task build: %i[clean gem]

    task install: :build do
      sh "gem install --pre #{gem}"
    end

    task push: :build do
      sh "gem push #{gem}"
    end
  end
end

namespace :all do
  task build: FRAMEWORKS.map { |framework| "#{framework}:build" }
  task install: FRAMEWORKS.map { |framework| "#{framework}:install" }
  task push: FRAMEWORKS.map { |framework| "#{framework}:push" }
end
