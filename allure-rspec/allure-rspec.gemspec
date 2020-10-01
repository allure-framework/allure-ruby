# frozen_string_literal: true

version = File.read(File.expand_path("../ALLURE_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "allure-rspec"
  s.version = version
  s.summary = "Allure rspec ruby adaptor"
  s.description = "Cucumber adaptor to generate rich allure test reports"
  s.homepage = "https://github.com/allure-framework/allure-ruby/tree/master/allure-rspec"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/allure-framework/allure-ruby/issues",
    "changelog_uri" => "https://github.com/allure-framework/allure-ruby/releases",
    "documentation_uri" => "https://github.com/allure-framework/allure-ruby/blob/master/allure-rspec/README.md",
    "source_code_uri" => "https://github.com/allure-framework/allure-ruby/tree/master/allure-rspec",
    "wiki_uri" => "https://github.com/allure-framework/allure-ruby/wiki"
  }

  s.required_ruby_version = ">= 2.5.0"

  s.license = "Apache-2.0"

  s.author = "Andrejs Cunskis"
  s.email = "andrejs.cunskis@gmail.com"

  s.files = Dir["README.md", "lib/**/*"]
  s.require_path = "lib"

  s.add_dependency "allure-ruby-commons", version
  s.add_dependency "rspec-core", "~> 3.8"
  s.add_dependency "ruby2_keywords", "~> 0.0.2"
end
