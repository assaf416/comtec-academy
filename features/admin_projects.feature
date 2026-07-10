Feature: Projects and documents (admin)
  Admins organise AI-generated documents under projects.

  Scenario: Admin adds a document to a project
    Given an active admin named "Assaf"
    And a project "Academy" with slug "academy"
    And I am signed in as "Assaf"
    When I open the project "academy"
    Then I see the document type slot "מסמך עיצוב"
    When I add the "design" document titled "Design" with content "# Design"
    Then I see the document "Design"
    And the rendered document contains a heading "Design"
