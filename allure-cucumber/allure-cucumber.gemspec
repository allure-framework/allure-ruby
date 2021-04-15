# frozen_string_literal: true

version = File.read(File.expand_path("../ALLURE_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "allure-cucumber"
  s.version = version
  s.summary = "Allure cucumber ruby adaptor"
  s.description = "Cucumber adaptor to generate rich allure test reports"
  s.homepage = "https://github.com/allure-framework/allure-ruby"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/allure-framework/allure-ruby/issues",
    "changelog_uri" => "https://github.com/allure-framework/allure-ruby/releases",
    "documentation_uri" => "https://github.com/allure-framework/allure-ruby/blob/master/allure-cucumber/README.md",
    "source_code_uri" => "https://github.com/allure-framework/allure-ruby/tree/master/allure-cucumber",
    "wiki_uri" => "https://github.com/allure-framework/allure-ruby/wiki"
  }

  s.required_ruby_version = ">= 2.5.0"

  s.license = "Apache-2.0"

  s.author = "Andrejs Cunskis"
  s.email = "andrejs.cunskis@gmail.com"

  s.files = Dir["README.md", "lib/**/*"]
  s.require_path = "lib"

  s.add_dependency "allure-ruby-commons", version
  s.add_dependency "cucumber", ">= 4.0.0", "< 7"
end
