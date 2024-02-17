# Allure Cucumber Adaptor

[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/allure-cucumber)

This repository contains Allure adaptor for [Cucumber](http://cukes.info/) framework.

## Cucumber versions

allure-cucumber versions <= 2.13.4 support only cucumber 3 and lower\
allure-cucumber versions >= 2.13.5 only support cucumber 4 and are not backwards compatible with cucumber 3 and lower

## Installation

Add this line to your application's Gemfile:

```ruby
gem "allure-cucumber"
```

And then execute:

```bash
  bundle
```

Or install it yourself as:

```bash
  gem install allure-cucumber
```

Require in "support/env.rb":

```ruby
require "allure-cucumber"
```

## Configuration

Common allure configuration is set via `AllureCucumber.configure` method. To change it, add the following in `features/support/env.rb` file:

```ruby
require "allure-cucumber"

AllureCucumber.configure do |config|
  config.results_directory = "report/allure-results"
  config.clean_results_directory = true
  config.logging_level = Logger::INFO
  config.logger = Logger.new($stdout, Logger::DEBUG)
  config.environment = "staging"
  config.failure_exception = RSpec::Expectations::ExpectationNotMetError

  # these are used for creating links to bugs or test cases where {} is replaced with keys of relevant items
  config.link_tms_pattern = "http://www.jira.com/browse/{}"
  config.link_issue_pattern = "http://www.jira.com/browse/{}"

  # additional metadata
  # environment.properties
  config.environment_properties = {
    custom_attribute: "foo"
  }
  # categories.json
  config.categories = File.new("my_custom_categories.json")
end
```

By default, allure-cucumber will analyze your cucumber tags looking for Test Management, Issue Management, and Severity tag as well
as custom tags for grouping tests in to epics, features and stories in Behavior tab of report. Links to TMS and ISSUE and test severity will be displayed in the report.

By default these prefixes are used:

```ruby
    DEFAULT_TMS_PREFIX      = 'TMS:'
    DEFAULT_ISSUE_PREFIX    = 'ISSUE:'
    DEFAULT_SEVERITY_PREFIX = 'SEVERITY:'
    DEFAULT_EPIC_PREFIX     = 'EPIC:'
    DEFAULT_FEATURE_PREFIX  = 'FEATURE:'
    DEFAULT_STORY_PREFIX    = 'STORY:'
```

Example:

```gherkin
  @SEVERITY:trivial @ISSUE:YZZ-100 @TMS:9901 @EPIC:custom-epic
  Scenario: Leave First Name Blank
    When I register an account without a first name
    Then exactly (1) [validation_error] should be visible
```

You can configure these prefixes as well as tms and issue tracker urls like this:

```ruby
AllureCucumber.configure do |config|
  config.tms_prefix      = 'HIPTEST--'
  config.issue_prefix    = 'JIRA++'
  config.severity_prefix = 'URGENCY:'
  config.epic_prefix = 'epic:'
  config.feature_prefix = 'feature:'
  config.story_prefix = 'story:'
end
```

Example:

```gherkin
  @URGENCY:critical @JIRA++YZZ-100 @HIPTEST--9901 @epic:custom-epic
  Scenario: Leave First Name Blank
    When I register an account without a first name
    Then exactly (1) [validation_error] should be visible
```

Additional special tags exists for setting status detail of test scenarios, allure will pick up following tags: `@flaky`, `@known` and `@muted`

### Custom failure exception

Allure report will mark steps and tests as either `Failed` or `Broken` based on exception class that was raised. By default, `RSpec::Expectations::ExpectationNotMetError` exception will mark test as `Failed` and all other exceptions will mark test as `Broken`.

Custom failure exception class can be configured:

```ruby
AllureCucumber.configure do |config|
  config.failure_exception = MyCustomFailedException
end
```

## Usage

Use `--format AllureCucumber::CucumberFormatter --out where/you-want-results` while running cucumber or add it to `cucumber.yml`. Note that cucumber `--out` option overrides `results_directory` set via `Allure.configure` method.

You can also manually attach screenshots and links to test steps and test cases by interacting with allure lifecycle directly. For more info check out `allure-ruby-commons`

```ruby
# file: features/support/env.rb

require "allure-cucumber"

Allure.add_attachment(name: "attachment", source: "Some string", type: Allure::ContentType::TXT, test_case: true)
Allure.add_link("Custom Url", "http://www.github.com")
```

It's possible to mark methods so those are included as allure steps: [Step annotations](../allure-ruby-commons/README.md#steps)

### Example project

[Cucumber Example](https://github.com/allure-examples/allure-cucumber-example)
