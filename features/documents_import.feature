Feature: Import a documents folder
  Admins bulk-import a folder of files into the Library, converting each to markdown.

  Scenario: Import markdown and HTML files
    Given a documents folder with a markdown and an HTML file
    When I import that documents folder
    Then 2 documents are in the library
    And every imported document keeps its original file
    And every imported document has markdown content
    And the imported HTML document excludes its stylesheet
