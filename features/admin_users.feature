Feature: Admin user management
  Admins invite users by their company email.

  Scenario: Admin invites a new user
    Given an active admin named "Assaf"
    And I am signed in as "Assaf"
    When I invite the user "newuser@comtecglobal.com"
    Then "newuser@comtecglobal.com" appears in the users list with status "invited"
