Feature: Search snippets and documents together
  The library search covers both documents and code snippets, filterable by
  language and project.

  Scenario: One search finds a document and a snippet
    Given an active student named "Dana"
    And a project "Alpha" with slug "alpha"
    And the project "alpha" has a "design" document titled "Batch design" with content "hello"
    And a snippet "Nightly batch" in "cobol" by "Dana"
    And I am signed in as "Dana"
    When I search the library for "batch"
    Then I see "Batch design" in the results
    And I see the snippet "Nightly batch" in the results

  Scenario: Filter snippet results by language
    Given an active student named "Dana"
    And a snippet "Nightly batch" in "cobol" by "Dana"
    And a snippet "Batch report" in "csharp" by "Dana"
    And I am signed in as "Dana"
    When I search the library for "batch" in language "cobol"
    Then I see the snippet "Nightly batch" in the results
    And I do not see the snippet "Batch report" in the results
