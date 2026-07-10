Feature: AI content generation
  Admins fill an episode's content with one click (stubbed AI).

  Scenario: Admin generates episode content with AI
    Given an active admin named "Assaf"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Blank" at position 1
    And I am signed in as "Assaf"
    When I generate content with AI for the episode "Blank" in "React Basics"
    Then the episode "Blank" has a title
    And the episode "Blank" has a transcript
