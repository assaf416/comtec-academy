Feature: Invitation and activation
  Users are invited by their company email and activate via an emailed link.

  Scenario: Invited user activates account
    Given an admin invites "newuser@comtecglobal.com"
    Then an invitation email is sent to "newuser@comtecglobal.com"
    When the user opens the activation link and sets password "secret123"
    Then the user "newuser@comtecglobal.com" is active
