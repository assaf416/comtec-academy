Feature: Asset loading
  The app renders without depending on render-blocking CDN assets, so pages
  don't hang blank when the browser can't reach a public CDN.

  Scenario: Pages do not load render-blocking CDN scripts
    When a visitor opens the sign in page
    Then no head script loads from a public CDN
    And the DataTables script is deferred and same-origin
    And Font Awesome is served from the app, not a CDN
