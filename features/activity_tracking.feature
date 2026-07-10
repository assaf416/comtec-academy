Feature: Activity tracking
  Admins can see what learners have been doing.

  Scenario: Admin sees a user's activity
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Intro" at position 1
    And I am signed in as "Dana"
    And I open the episode "Intro" in "React Basics"
    Given an active admin named "Assaf"
    And I am signed in as "Assaf"
    When I open the activity dashboard
    Then I see a "viewed_episode" activity for "Dana"
