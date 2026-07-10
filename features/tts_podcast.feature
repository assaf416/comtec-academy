Feature: Hebrew TTS podcast
  Admins generate Hebrew podcast audio for an episode (stubbed TTS).

  Scenario: Admin generates Hebrew audio
    Given an active admin named "Assaf"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Intro" with transcript "hello transcript"
    And I am signed in as "Assaf"
    When I generate the Hebrew podcast for the episode "Intro" in "React Basics"
    Then the episode "Intro" has an audio attachment
