Feature: Branded document rendering
  Rendered documents carry the company brand colours and logo.

  Scenario: Document renders with the brand theme
    Given an active admin named "Assaf"
    And a project "Academy" with slug "academy"
    And the project "academy" has a "design" document titled "Design" with content "# Design"
    And the brand primary color is "#ff0055"
    And I am signed in as "Assaf"
    When I view the "design" document of "academy"
    Then the page includes the brand color "#ff0055"
    And the page loads a Google font
