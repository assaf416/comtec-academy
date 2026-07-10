Feature: Course catalog
  Authenticated users browse published courses and open one.

  Scenario: Active user browses courses
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And I am signed in as "Dana"
    When I visit the courses page
    Then I see the course "React Basics"
    When I open the course "React Basics"
    Then I am on the course page for "React Basics"
