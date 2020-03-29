# allure-rspec

[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/allure-rspec)

Allure adapter for [rspec](https://rspec.info/) testing framework

## Installation

Add it to gemfile:

```ruby
gem "allure-rspec"
```

Require in `spec_helper` or any other setup file:

```ruby
require "allure-rspec"
```

## Configuration

Following configuration options are supported:

```ruby
    AllureRspec.configure do |config|
      config.results_directory = "/whatever/you/like"
      config.clean_results_directory = true
      config.logging_level = Logger::INFO
      # these are used for creating links to bugs or test cases where {} is replaced with keys of relevant items
      config.link_tms_pattern = "http://www.jira.com/browse/{}"
      config.link_issue_pattern = "http://www.jira.com/browse/{}"
    end
```

## Usage

Via commandline arguments, simply add:

```bash
--format AllureRspecFormatter
```

or

Via RSpec configuration:

```ruby
RSpec.configure do |config|
  config.formatter = AllureRspecFormatter
end
```

### Adding tms links

Configure tms link pattern:

```ruby
AllureRspec.configure do |config|
  config.link_tms_pattern = "http://www.jira.com/browse/{}"
end
```

Add tag to rspec test:

```ruby
it "some test case", tms: "QA-123" do
  # test
end
```

It's possible to add multiple tms links using `tms_` pattern:

```ruby
it "some test case", tms_1: "QA-123", tms_2: "QA-124" do
  # test
end
```

### Adding issue links

Configure issue link pattern:

```ruby
AllureRspec.configure do |config|
  config.link_issue_pattern = "http://www.jira.com/browse/{}"
end
```

Add tag to rspec test:

```ruby
it "some test case", issue: "QA-123" do
  # test
end
```

It's possible to add multiple tms links using `issue_` pattern:

```ruby
it "some test case", issue_1: "QA-123", issue_2: "QA-124" do
  # test
end
```

### Adding custom severity and status details

Test severity (`normal` by default) can be changed via `severity` tag:

```ruby
it "some test case", severity: :critical do
  # test
end
```

Custom status details can be set via `muted`, `known`, `flaky` tags:

```ruby
it "some test case", flaky: true, muted: false, known: true do
  # test
end
```

### Adding additional labels to allure test case

Additional labels can be added using `allure_` pattern:

```ruby
it "some test case", allure_1: "visual_test", allure_2: "core_functionality" do
  # test
end
```

### Custom actions

Rspec example object has access to [Allure](https://www.rubydoc.info/github/allure-framework/allure-ruby/Allure) helper methods.
It can be used to add or run steps, add attachments, modify test case etc.

```ruby
it "some test case" do |e|
  e.run_step("my custom step") do
    # some action
  end
  e.add_attachment(name: "attachment", source: "Some string", type: Allure::ContentType::TXT)
end
```

### Example project

[RSpec Example](https://github.com/allure-examples/allure-rspec-example)

## HTML report generation

Report is generated using allure commandline tool. [Allure wiki](https://docs.qameta.io/allure/#_reporting).
