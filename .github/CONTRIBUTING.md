# Contributing

We love pull requests from everyone.

## Setup

**Fork, then clone the repo:**

```bash
git clone git@github.com:your-username/allure-ruby.git
```

**Install dependencies (project requires ruby version 2.5):**

```bash
bundle install
```

**Optionally setup rubocop git [pre-commit](https://pre-commit.com) hook**

```bash
pre-commit install
```

## Testing

**Make your change. Add tests for your change. Make sure all the tests pass and coverage is good:**

```bash
COV_HTML_REPORT=true bundle exec rake test_with_coverage
```

## Building

**To test changes locally, bump version and build gems**

```bash
bundle exec rake build
```

All gems will be built in `pkg` folder

**Install gem with**

```bash
gem install pkg/allure-cucumber-${ALLURE_VERSION}.gem
```

**After everything is tested, push your fork and submit a pull request.**
