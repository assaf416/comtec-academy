Feature: Learner screens show data in DataTables tables
  Card grids on learner-facing screens are replaced by DataTables-enabled tables,
  consistent with the admin screens (S29). Each list renders a
  <table data-controller="datatable"> and keeps its existing links/actions.

  Scenario: Course catalog is a datatable
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And I am signed in as "Dana"
    When I visit the courses page
    Then the page has a datatable
    And I see the course "React Basics"

  Scenario: Course episodes are shown in a datatable
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Intro" at position 1
    And I am signed in as "Dana"
    When I open the course "React Basics"
    Then the page has a datatable
    And I see the course "Intro"

  Scenario: Presentations are a datatable
    Given an active student named "Dana"
    And a published presentation "Kickoff"
    And I am signed in as "Dana"
    When I open the presentations viewer
    Then the page has a datatable
    And I see the presentation "Kickoff"

  Scenario: Library lists are datatables
    Given an active student named "Dana"
    And a project "Alpha" with slug "alpha"
    And the project "alpha" has a "design" document titled "Setup Guide" with content "hello"
    And I am signed in as "Dana"
    When I open the library
    Then the page has a datatable
    And I see "Setup Guide" in the library
