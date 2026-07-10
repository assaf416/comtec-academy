Feature: Quiz answers
  A quiz episode captures and stores the user's answer for later use.

  Scenario: User answers a quiz
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a quiz episode "Checkpoint" asking "2+2?"
    And I am signed in as "Dana"
    When I open the episode "Checkpoint" in "React Basics"
    And I answer the quiz with "4"
    Then my answer "4" is stored for that quiz
