# frozen_string_literal: true

version = File.read(File.expand_path("../ALLURE_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "allure-ruby-commons"
  s.version = version
  s.summary = "Common library for allure results generation"
  s.description = "Utilities allowing to implement allure result generation by other test frameworks"
  s.homepage = "https://github.com/allure-framework/allure-ruby"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/allure-framework/allure-ruby/issues",
    "changelog_uri" => "https://github.com/allure-framework/allure-ruby/releases",
    "documentation_uri" => "https://github.com/allure-framework/allure-ruby/blob/master/allure-ruby-commons/README.md",
    "source_code_uri" => "https://github.com/allure-framework/allure-ruby/tree/master/allure-ruby-commons",
    "wiki_uri" => "https://github.com/allure-framework/allure-ruby/wiki",
    "rubygems_mfa_required" => "false"
  }

  s.required_ruby_version = ">= 3.0.0"

  s.license = "Apache-2.0"

  s.author = "Andrejs Cunskis"
  s.email = "andrejs.cunskis@gmail.com"

  s.files = Dir["README.md", "lib/**/*"]
  s.require_path = "lib"

  s.add_dependency "mime-types", ">= 3.3", "< 4"
  s.add_dependency "require_all", ">= 2", "< 4"
  s.add_dependency "rspec-expectations", "~> 3.12"
  s.add_dependency "uuid", ">= 2.3", "< 3"
end
