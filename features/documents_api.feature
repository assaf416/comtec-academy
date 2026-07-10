Feature: Documents API
  An agent pushes AI-generated documents to a project via the shared-secret API.

  Scenario: Upsert a document with the API key
    Given a project "Academy" with slug "academy"
    When the API upserts the "design" document for "academy" with title "Design" and content "# Design doc"
    Then the API response is 200
    And the project "academy" has a "design" document titled "Design"

  Scenario: Re-sending replaces the document, not duplicates it
    Given a project "Academy" with slug "academy"
    When the API upserts the "design" document for "academy" with title "V1" and content "# one"
    And the API upserts the "design" document for "academy" with title "V2" and content "# two"
    Then the project "academy" has exactly 1 document
    And the project "academy" has a "design" document titled "V2"

  Scenario: A wrong API key is rejected
    Given a project "Academy" with slug "academy"
    When the API upserts the "design" document for "academy" with a bad key
    Then the API response is 401
