Feature: Simple feature

  @before
  Scenario: Add a to b
    Simple scenario description
    Given a is 5
    And b is 10
    When I add a to b
    Then result is 15

  @after
  Scenario: Add a to b
    Simple scenario description
    Given a is 5
    And b is 10
    When I add a to b
    Then result is 15

  @broken_hook
  Scenario: Add a to b
    Simple scenario description
    Given a is 5
    And b is 10
    When I add a to b
    Then result is 15
