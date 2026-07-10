Feature: Responsive framework split
  Mobile visitors get Bulma; web visitors get Bootstrap.

  Scenario: Mobile visitor gets Bulma
    When a visitor opens the sign in page with view "mobile"
    Then the page uses the "bulma" stylesheet

  Scenario: Web visitor gets Bootstrap
    When a visitor opens the sign in page with view "web"
    Then the page uses the "bootstrap" stylesheet
