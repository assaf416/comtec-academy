Feature: Movie playback
  A movie episode shows the video player and the transcript.

  Scenario: User watches a movie episode
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Intro" with transcript "hello transcript"
    And I am signed in as "Dana"
    When I open the episode "Intro" in "React Basics"
    Then I see a video player
    And I see the transcript "hello transcript"
