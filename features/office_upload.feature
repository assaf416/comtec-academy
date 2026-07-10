Feature: Office upload
  Admins upload Word/Excel files; each is converted to markdown and the original is kept.

  Scenario: Admin uploads an office file
    Given an active admin named "Assaf"
    And I am signed in as "Assaf"
    When I upload the office file "sample.xlsx"
    Then a library document is created from "sample.xlsx"
    And that document keeps its original file
    And that document has markdown content
