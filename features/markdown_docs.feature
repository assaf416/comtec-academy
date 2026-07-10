Feature: Markdown docs
  An episode may show one or more named markdown documents, rendered.

  Scenario: Episode shows attached markdown
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Intro" at position 1
    And the episode "Intro" has a markdown doc "Notes" with content "# Hello"
    And I am signed in as "Dana"
    When I open the episode "Intro" in "React Basics"
    Then I see the document "Notes"
    And the document renders a heading "Hello"
