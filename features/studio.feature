Feature: Studio movie assembly
  Admins assemble an episode movie in the studio (ffmpeg).

  Scenario: Admin assembles a movie
    Given an active admin named "Assaf"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Intro" with transcript "hello transcript"
    And I am signed in as "Assaf"
    When I assemble the movie for the episode "Intro" in "React Basics"
    Then the episode "Intro" has a movie attachment
