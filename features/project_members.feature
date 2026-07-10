Feature: Project members and avatars
  Users are imported from the roster with their projects, and project pages show member avatars.

  Scenario: Import the roster into users, projects and memberships
    When I import the users roster
    Then at least 15 users are imported
    And the user "יוסי כהן" belongs to project "תשתיות"
    And the user "יוסי כהן" has an avatar

  Scenario: Project page shows member avatars
    Given an active admin named "Assaf"
    And a project "Alpha" with slug "alpha"
    And the project "alpha" has 3 members
    And I am signed in as "Assaf"
    When I open the admin project "alpha"
    Then I see 3 avatars in the members stack

  Scenario: Large teams collapse into a +N overflow
    Given an active admin named "Assaf"
    And a project "Alpha" with slug "alpha"
    And the project "alpha" has 10 members
    And I am signed in as "Assaf"
    When I open the admin project "alpha"
    Then I see 8 avatars in the members stack
    And I see a "+2" overflow in the members stack
