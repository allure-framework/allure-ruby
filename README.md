# Allure ruby

[![Gem Version](https://badge.fury.io/rb/allure-ruby-commons.svg)](https://rubygems.org/gems/allure-ruby-commons)
[![Total Downloads](https://img.shields.io/gem/dt/allure-ruby-commons?color=blue)](https://rubygems.org/gems/allure-ruby-commons)
![Workflow status](https://github.com/allure-framework/allure-ruby/workflows/Test/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/3190a4c9e68f20dd82ec/maintainability)](https://codeclimate.com/github/allure-framework/allure-ruby/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/3190a4c9e68f20dd82ec/test_coverage)](https://codeclimate.com/github/allure-framework/allure-ruby/test_coverage)
[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://rubydoc.info/github/allure-framework/allure-ruby/master)
[![Test Report](https://img.shields.io/badge/report-allure-blue.svg)](https://storage.googleapis.com/allure-test-reports/allure-ruby/refs/heads/master/index.html)

Ruby testing framework adaptors for generating allure compatible test reports.

## Supported frameworks

### allure-cucumber

[![Gem Version](https://badge.fury.io/rb/allure-cucumber.svg)](https://rubygems.org/gems/allure-cucumber)
[![Downloads](https://img.shields.io/gem/dt/allure-cucumber?color=blue)](https://rubygems.org/gems/allure-cucumber)

```ruby
gem "allure-cucumber"
```

Implementation of allure adaptor for [Cucumber](https://github.com/cucumber/cucumber-ruby) testing framework

Detailed usage and setup instruction can be found in [allure-cucumber docs](allure-cucumber/README.md)

### allure-rspec

[![Gem Version](https://badge.fury.io/rb/allure-rspec.svg)](https://rubygems.org/gems/allure-rspec)
[![Downloads](https://img.shields.io/gem/dt/allure-rspec?color=blue)](https://rubygems.org/gems/allure-rspec)

```ruby
gem "allure-rspec"
```

Implementation of allure adaptor for [RSpec](https://github.com/rspec/rspec) testing framework

Detailed usage and setup instruction can be found in [allure-rspec docs](allure-rspec/README.md)

## Development

### allure-ruby-commons

[![Gem Version](https://badge.fury.io/rb/allure-ruby-commons.svg)](https://rubygems.org/gems/allure-ruby-commons)

```ruby
gem "allure-ruby-commons"
```

Common allure lifecycle interface to be used by other testing frameworks to generate allure reports

Interaction and usage of allure lifecycle is described in [allure-ruby-commons docs](allure-ruby-commons/README.md)

### Contributing

- Install dependencies:

```console
$ bundle install
Bundle complete! ...
```

- Make changes

- Run linter:

```console
$ bundle exec rake rubocop
Executing rubocop for allure-cucumber
...
no offenses detected

Executing rubocop for allure-rspec
...
no offenses detected

Executing rubocop for allure-ruby-commons
...
no offenses detected
```

- Run tests:

```console
$ bundle exec rake test
Executing test for allure-cucumber
...
0 failures

Executing test for allure-rspec
...
0 failures

Executing test for allure-ruby-commons
...
0 failures
```

- Submit a PR

### Releasing

New version can be created by triggering manual `Release` workflow

## Generating HTML report

Ruby binding hosted in this repository only generate source json files for the [allure2](https://github.com/allure-framework/allure2) reporter.

See [documentation](https://allurereport.org/) on how to use allure report.

### Using with CI providers

[allure-report-publisher](https://github.com/andrcuns/allure-report-publisher) provides a docker image which can be run from github-actions
workflow or gitlab-ci pipeline and host reports using cloud providers like AWS or GCP.
