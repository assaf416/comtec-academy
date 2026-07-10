Feature: Import a documents folder
  Admins bulk-import a folder of files into the Library, converting each to markdown.

  Scenario: Import markdown and HTML files
    Given a documents folder with a markdown and an HTML file
    When I import that documents folder
    Then 2 documents are in the library
    And every imported document keeps its original file
    And every imported document has searchable content
    And the imported HTML document's content excludes its stylesheet

  Scenario: HTML documents open as their raw original file
    Given an active admin named "Assaf"
    And I am signed in as "Assaf"
    And a documents folder with a markdown and an HTML file
    When I import that documents folder
    And I open the raw view of "Page"
    Then the raw response is the original HTML with its stylesheet
