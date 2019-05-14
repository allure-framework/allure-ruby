# frozen_string_literal: true

version = File.read(File.expand_path("../ALLURE_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "allure-cucumber"
  s.version = version
  s.summary = "Allure cucumber ruby adapter"
  s.description = "Cucumber adapter to generate rich allure test reports"

  s.required_ruby_version = ">= 2.5.0"

  s.license = "Apache-2.0"

  s.author = "Andrejs Cunskis"
  s.email = "andrejs.cunskis@gmail.com"
  s.homepage = "http://allure.qatools.ru"

  s.files = Dir["README.md", "lib/**/*"]
  s.require_path = "lib"

  s.add_dependency "allure-ruby-commons", version
  s.add_dependency "cucumber" , "~> 3.1"
end
