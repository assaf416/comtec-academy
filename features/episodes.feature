Feature: Episodes
  A course lists its episodes (movie or quiz) in order.

  Scenario: Course lists its episodes in order
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Intro" at position 1
    And the course "React Basics" has a quiz episode "Checkpoint" at position 2
    And I am signed in as "Dana"
    When I open the course "React Basics"
    Then I see episodes in order "Intro, Checkpoint"
