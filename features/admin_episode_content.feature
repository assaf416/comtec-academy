Feature: Episode content editing
  Admins create and edit episode content.

  Scenario: Admin edits episode content
    Given an active admin named "Assaf"
    And a published course "React Basics" with details "Learn React"
    And I am signed in as "Assaf"
    When I add a movie episode titled "Intro" with transcript "hello world" to "React Basics"
    Then the course "React Basics" has an episode "Intro" with transcript "hello world"
