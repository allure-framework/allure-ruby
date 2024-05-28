# frozen_string_literal: true

source "https://rubygems.org"

gem "allure-cucumber", path: "allure-cucumber"
gem "allure-rspec", path: "allure-rspec"
gem "allure-ruby-commons", path: "allure-ruby-commons"

group :development do
  gem "colorize", "~> 1.1.0"
  gem "debug", "~> 1.8"
  gem "rake", "~> 13.2.1"
  gem "semver2", "~> 3.4"
  gem "solargraph", "~> 0.50.0"
end

group :test do
  gem "climate_control", "~> 1.2.0"
  gem "oj", "~> 3.14" if ENV["WITH_OJ_GEM"] == "true"
  gem "rspec", "~> 3.13.0"
  gem "rubocop", "~> 1.64.0"
  gem "rubocop-performance", "~> 1.21.0"
  gem "simplecov", "~> 0.22.0"
  gem "simplecov-console", "~> 0.9.1"
end
