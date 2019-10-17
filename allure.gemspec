# frozen_string_literal: true

version = File.read(File.expand_path("ALLURE_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "allure-ruby"
  s.version = version
  s.summary = "Allure ruby commons and ruby testing framework adaptors"

  s.required_ruby_version = ">= 2.5.0"

  s.license = "Apache-2.0"

  s.author = "Andrejs Cunskis"
  s.email = "andrejs.cunskis@gmail.com"
  s.homepage = "http://allure.qatools.ru"

  s.add_dependency "allure-ruby-commons", version
  s.add_dependency "allure-cucumber", version
  s.add_dependency "allure-rspec", version

  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "pry", "~> 0.12.2"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec", "~> 3.8"
  s.add_development_dependency "rubocop", "~> 0.74"
  s.add_development_dependency "rubocop-performance", "~> 1.4"
  s.add_development_dependency "solargraph", "~> 0.35"
  s.add_development_dependency "colorize", "~> 0.8"
  s.add_development_dependency "simplecov", "~> 0.16"
  s.add_development_dependency "coveralls", "~> 0.8"
  s.add_development_dependency "semantic", "~> 1.6"
  s.add_development_dependency "lefthook", "~> 0.6.3"
end
