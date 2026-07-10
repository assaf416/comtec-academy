Feature: DataTables and kebab row menus
  Admin index tables are DataTables with per-row kebab action menus.

  Scenario: Users index is a datatable with a kebab actions menu
    Given an active admin named "Assaf"
    And I am signed in as "Assaf"
    When I open the admin users page
    Then the page has a datatable
    And a row has a kebab actions menu
    And the kebab menu offers the action "עריכה"
