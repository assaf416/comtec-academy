Feature: The Library
  All signed-in users browse documents across projects in one place.

  Scenario: Documents across projects appear in the library
    Given an active admin named "Assaf"
    And a project "Alpha" with slug "alpha"
    And the project "alpha" has a "design" document titled "Alpha Design" with content "# A"
    And I am signed in as "Assaf"
    When I open the library
    Then I see "Alpha Design" in the library

  Scenario: Viewed documents surface under Popular
    Given an active admin named "Assaf"
    And a project "Alpha" with slug "alpha"
    And the project "alpha" has a "design" document titled "Alpha Design" with content "# A"
    And the document "Alpha Design" has 7 views
    And I am signed in as "Assaf"
    When I open the library
    Then I see "Alpha Design" under "popular"
