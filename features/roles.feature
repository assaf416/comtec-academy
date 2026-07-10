Feature: Roles
  Only admins may reach the admin area; students are redirected.

  Scenario: Student cannot access admin
    Given an active student named "Dana"
    When "Dana" visits the admin dashboard
    Then access is denied

  Scenario: Admin can access admin
    Given an active admin named "Assaf"
    When "Assaf" visits the admin dashboard
    Then the admin dashboard is shown
