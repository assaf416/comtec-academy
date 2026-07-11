Feature: Share code snippets
  Comtec engineers share code snippets (COBOL/AS400, C#, web) with each other,
  browsed in a DataTables list and viewed with syntax highlighting.

  Scenario: Engineer shares a COBOL snippet
    Given an active student named "Dana"
    And I am signed in as "Dana"
    When I create a snippet titled "Nightly batch" in language "cobol"
    Then the snippet "Nightly batch" is listed
    And I can view the snippet "Nightly batch" with highlighted code

  Scenario: Another engineer can view a shared snippet
    Given an active student named "Dana"
    And an active student named "Noa"
    And a snippet "Payroll calc" in "csharp" by "Dana"
    And I am signed in as "Noa"
    When I visit the snippets page
    Then the page has a datatable
    And the snippet "Payroll calc" is listed
    And I can view the snippet "Payroll calc" with highlighted code
