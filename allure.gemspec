# frozen_string_literal: true

version = File.read(File.expand_path("ALLURE_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "allure-ruby"
  s.version = version
  s.summary = "Allure ruby commons and ruby testing framework adapters"

  s.required_ruby_version = ">= 2.5.0"

  s.license = "Apache-2.0"

  s.author = "Andrejs Cunskis"
  s.email = "andrejs.cunskis@gmail.com"
  s.homepage = "http://allure.qatools.ru"

  s.add_dependency "allure-ruby-commons", version
  s.add_dependency "allure-cucumber", version
end
