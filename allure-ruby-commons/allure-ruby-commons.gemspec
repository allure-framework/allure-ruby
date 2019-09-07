# frozen_string_literal: true

version = File.read(File.expand_path("../ALLURE_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "allure-ruby-commons"
  s.version = version
  s.summary = "Common library for allure results generation"
  s.description = "Utilities allowing to implement allure result generation by other test frameworks"
  s.homepage = "https://github.com/allure-framework/allure-ruby"

  s.required_ruby_version = ">= 2.5.0"

  s.license = "Apache-2.0"

  s.author = "Andrejs Cunskis"
  s.email = "andrejs.cunskis@gmail.com"

  s.files = Dir["README.md", "lib/**/*"]
  s.require_path = "lib"

  s.add_dependency "uuid", "~> 2.3.9"
  s.add_dependency "require_all", "~> 2.0"
  s.add_dependency "json", ">= 1.8", "< 3"
  s.add_dependency "rubyzip", "~> 1.2"
end
