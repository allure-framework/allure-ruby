# Allure Ruby Adaptor API

[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/allure-ruby-commons)

This is a helper library containing the basics for any ruby-based Allure adaptor.
Using it you can easily implement the adaptor for your favorite ruby testing library or
you can just create the report of any other kind using the basic Allure terms.

## Setup

Add the dependency to your Gemfile

```ruby
 gem "allure-ruby-commons"
```

## Configuration

Following configuration options are supported:

```ruby
    Allure.configure do |config|
      config.results_directory = "report/allure-results"
      config.clean_results_directory = true
      config.logging_level = Logger::INFO
      config.logger = Logger.new($stdout, Logger::DEBUG)
      config.environment = "staging"

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

Getting the configuration object:

```ruby
Allure.configuration
```

### Allure execution environment

It is possible to set up custom allure environment which will be used as custom parameter `environment` in every test case. This is useful if you run same tests on different environments and generate single report. This way different runs are not put as retry. Environment can be configured in following ways:

* via `ALLURE_ENVIRONMENT` environment variable
* via `configure` method

### Environment properties

To add additional environment information to the report it is possible to set configuration property `environment_properties`.

Option can be set to hash or block returning a hash:

```ruby
# hash
config.environment_properties = {
        custom_attribute: "foo"
      }

# lambda
config.environment_properties = -> { { custom_attributes: "foo"} }
```

### Log level

Log level can be also configured via environment variable `ALLURE_LOG_LEVEL` which accepts one of the following values: `DEBUG INFO WARN ERROR FATAL UNKNOWN`.

## Allure lifecycle

Reports are built using API defined in AllureLifecycle class and using allure specific entities defined in models.
Example of building a simple test case can be seen in [integration spec](spec/integration/full_report_spec.rb).

Convenience method `Allure.lifecycle` exists for getting thread specific allure lifecycle instance.

Additional methods in [Allure](lib/allure-ruby-commons.rb) exist to add various custom attributes to test report.

```ruby
Allure.add_attachment(name: "attachment", source: "Some string", type: Allure::ContentType::TXT, test_case: false)
Allure.add_attachment(name: "attachment", source: "/path/to/test.txt", type: Allure::ContentType::TXT, test_case: false)
Allure.add_link(name: "Custom Url", url: "http://www.github.com")
```

## Steps

It is possible to mark method definitions to be automatically added to report as steps. The class just needs to extend `AllureStepAnnotation`
and `step` method needs to be used before the method definition.

```ruby
class TestHelper
  extend AllureStepAnnotation

  step("Singleton step")
  def self.class_method; end

  step("Standard step")
  def standard_method; end
end
```
