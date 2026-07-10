Feature: Library search
  Users search and filter documents by name, project, kind and tag.

  Background:
    Given an active admin named "Assaf"
    And a project "Alpha" with slug "alpha"
    And a project "Beta" with slug "beta"
    And the project "alpha" has a "design" document titled "Alpha Design" with content "# A"
    And the project "beta" has a "models" document titled "Beta Models" with content "# B"
    And the document "Alpha Design" is tagged "security"
    And I am signed in as "Assaf"

  Scenario: Search by name
    When I search the library for "Alpha"
    Then I see "Alpha Design" in the results
    And I do not see "Beta Models" in the results

  Scenario: Filter by project
    When I filter the library by project "beta"
    Then I see "Beta Models" in the results
    And I do not see "Alpha Design" in the results

  Scenario: Filter by kind
    When I filter the library by kind "models"
    Then I see "Beta Models" in the results
    And I do not see "Alpha Design" in the results

  Scenario: Filter by tag
    When I filter the library by tag "security"
    Then I see "Alpha Design" in the results
    And I do not see "Beta Models" in the results
