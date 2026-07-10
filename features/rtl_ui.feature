Feature: RTL Hebrew UI
  The UI is in Hebrew and all screens are right-to-left.

  Scenario: Pages render right-to-left in Hebrew
    When a visitor opens the sign in page
    Then the page is right-to-left in Hebrew
