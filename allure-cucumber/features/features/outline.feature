Feature: Simple scenario outline feature

  Scenario Outline: Add a to b
    Given a is <num_a>
    And b is <num_b>
    When I add a to b
    Then result is <result>
    Examples:
      | num_a | num_b | result |
      | 5     | 10    | 15     |
      | 6     | 7     | 13     |
