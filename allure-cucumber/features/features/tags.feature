@FeatureTag
@TMS:OAT-4444
@flaky
@ISSUE:BUG-22400
Feature: Test Simple Scenarios

  @good @SEVERITY:blocker
  Scenario: Add a to b
    Given a is 5
    And b is 10
    When I add a to b
    Then result is 15

  @status_details @flaky @muted @known
  Scenario: Add a to b
    Given a is 5
    And b is 10
    When I add a to b
    Then result is 15

