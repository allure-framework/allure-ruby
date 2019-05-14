Feature: Simple feature

  @broken
  Scenario: Add a to b
    Simple scenario description
    Given a is 5
    And b is 10
    When I add a to b
    Then step fails with simple exception
    And this step shoud be skipped
  
  @failed
  Scenario: Add a to b
    Simple scenario description
    Given a is 5
    And b is 10
    When I add a to b
    Then result is 16
