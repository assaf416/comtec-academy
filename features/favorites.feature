Feature: Favorite documents
  Users mark documents as favorites and find them in the Library.

  Scenario: Favorite a document
    Given an active admin named "Assaf"
    And a project "Alpha" with slug "alpha"
    And the project "alpha" has a "design" document titled "Alpha Design" with content "# A"
    And I am signed in as "Assaf"
    When I open the document "Alpha Design"
    And I favorite the document
    Then "Alpha Design" is in my favorites
    When I open the library
    Then I see "Alpha Design" under "favorites"
