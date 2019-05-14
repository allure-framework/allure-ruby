# Allure Cucumber Adaptor

This repository contains Allure adaptor for [Cucumber](http://cukes.info/) framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'allure-cucumber'
```
And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install allure-cucumber
```

## Configuration

By default, Allure json files are stored in `reports/allure-results`. To change this add the following in `features/support/env.rb` file:

```ruby
Allure.configure do |c|
   c.results_directory = "/output/dir"
end
```

By default, allure-cucumber will analyze your cucumber tags looking for Test Management, Issue Management, and Severity hooks. Links to TMS and ISSUE and test severity will be displayed in the report. By default these prefixes are used:

```ruby    
    DEFAULT_TMS_PREFIX      = 'TMS:'
    DEFAULT_ISSUE_PREFIX    = 'ISSUE:'
    DEFAULT_SEVERITY_PREFIX = 'SEVERITY:'
```

Example: 
```gherkin
  @SEVERITY:trivial @ISSUE:YZZ-100 @TMS:9901
  Scenario: Leave First Name Blank
    When I register an account without a first name
    Then exactly (1) [validation_error] should be visible
```    

You can configure these prefixes as well as tms and issue tracker urls like this:

```ruby
Allure.configure do |c|
  c.link_tms_pattern = "http://www.hiptest.com/tms/{}"
  c.link_issue_pattern = "http://www.jira.com/browse/{}"
  c.tms_prefix      = 'HIPTEST--'
  c.issue_prefix    = 'JIRA++'
  c.severity_prefix = 'URGENCY:'
end
```

Example: 
```gherkin
  @URGENCY:critical @JIRA++YZZ-100 @HIPTEST--9901
  Scenario: Leave First Name Blank
    When I register an account without a first name
    Then exactly (1) [validation_error] should be visible
```    

Additional special tags exists for setting status detail of test scenarios, allure will pick up following tags: `@flaky`, `@known` and `@muted`

## Usage

Put the following in your `features/support/env.rb` file:

```ruby
require 'allure-cucumber'
```

Use `--format Allure::CucumberFormatter --out where/you-want-results` while running cucumber or add it to `cucumber.yml`

You can also manually attach screenshots and links to test steps and test cases by interacting with allure lifecycle directly. For more info check out `allure-ruby-commons`

```ruby
# file: features/support/env.rb

require "allure-cucumber"

Allure.add_attachment(name: "attachment", source: "Some string", type: Allure::ContentType::TXT, test_case: true)
Allure.add_link("Custom Url", "http://www.github.com")
```

## How to generate report
This adapter only generates json files containing information about tests. See [wiki section](https://docs.qameta.io/allure/#_reporting) on how to generate report.
