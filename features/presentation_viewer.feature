Feature: Presentation viewer
  Slides carry layouts and quizzes; signed-in users watch published presentations.

  Scenario: Layout and quiz directives shape the slides
    When I build a presentation with a code-en slide and a quiz slide
    Then slide 2 uses layout "code-en"
    And the quiz slide has choices and a correct answer

  Scenario: Only published presentations are watchable
    Given an active admin named "Assaf"
    And a published presentation "Intro"
    And a draft presentation "Secret"
    And I am signed in as "Assaf"
    When I open the presentations viewer
    Then I see the presentation "Intro"
    And I do not see the presentation "Secret"

  Scenario: A viewer answers a quiz slide
    Given an active admin named "Assaf"
    And a published presentation with a quiz slide
    And I am signed in as "Assaf"
    When I open that presentation
    And I answer the quiz slide with "מציג שינויים"
    Then my quiz answer is stored and correct
