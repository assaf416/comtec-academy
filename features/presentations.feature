Feature: Presentation builder
  Admins turn a markdown screenplay into narrated slides and a DAW-style builder.

  Scenario: Screenplay parses into slides with notes
    Given an active admin named "Assaf"
    And I am signed in as "Assaf"
    When I create a presentation from the sample screenplay
    Then the presentation has 3 slides
    And slide 2 is a code slide
    And slide 1 has narration notes

  Scenario: Generating audio attaches voice-over per narrated slide
    Given a presentation from the sample screenplay
    When the presentation audio is generated
    Then every narrated slide has an audio attachment

  Scenario: The builder page shows the DAW
    Given an active admin named "Assaf"
    And a presentation from the sample screenplay
    And I am signed in as "Assaf"
    When I open the presentation builder
    Then I see the 4 timeline tracks
    And I see the preview stage
