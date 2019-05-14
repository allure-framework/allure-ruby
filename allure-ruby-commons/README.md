# Allure Ruby Adaptor API

This is a helper library containing the basics for any ruby-based Allure adaptor.
Using it you can easily implement the adaptor for your favorite ruby testing library or
you can just create the report of any other kind using the basic Allure terms.

## Setup

Add the dependency to your Gemfile

```ruby
 gem 'allure-ruby-commons'
```

## Configuration

Following configuration options are supported:

```ruby
    Allure.configure do |c|
      c.results_directory = "/whatever/you/like"
      c.logging_level = Logger::INFO
      # these are used for creating links to bugs or test cases where {} is replaced with keys of relevant items
      c.link_tms_pattern = "http://www.jira.com/browse/{}"
      c.link_issue_pattern = "http://www.jira.com/browse/{}"
    end
```

Getting the configuration object:

```ruby
Allure.configuration
```

## Allure lifecycle

Reports are built using API defined in AllureLifecycle class and using allure specific entities defined in models.
Example of building a simple test case can be seen in [integration spec](spec/integration/full_report_spec.rb).

Convenience method `Allure.lifecycle` exists for getting thread specific allure lifecycle instance.

Additional methods in [Allure](lib/allure-ruby-commons.rb) exist to add various custom attributes to test report.

```ruby
Allure.add_attachment(name: "attachment", source: "Some string", type: Allure::ContentType::TXT, test_case: false)
Allure.add_link(name: "Custom Url", url: "http://www.github.com")
```

## Testing

Install dependencies:

```bash
bundle install
```

Run tests:

```bash
bundle exec rspec
```

## Building

```bash
gem build allure-ruby-commons.gemspec
```
