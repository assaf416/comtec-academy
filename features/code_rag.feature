Feature: Code-aware retrieval across projects
  The code chat retrieves related code from across Comtec's projects (COBOL, C#,
  web) and cites the sources it used — without hallucinating sources when none
  are relevant.

  Scenario: Cross-project question pulls relevant code
    Given an active student named "Dana"
    And a snippet "Payroll main" in "csharp" by "Dana"
    And a snippet "Payroll helper" in "cobol" by "Dana"
    And I am signed in as "Dana"
    When I open the snippet "Payroll main"
    And I post the code chat message "how is payroll calculated?"
    Then the code chat reply cites the source "Payroll helper"

  Scenario: A lone snippet cites no sources
    Given an active student named "Dana"
    And a snippet "Solo util" in "sql" by "Dana"
    And I am signed in as "Dana"
    When I open the snippet "Solo util"
    And I post the code chat message "explain this"
    Then the code chat reply cites no sources
