Feature: Episode chat
  Every episode has a chat thread; each message is kept.

  Scenario: User posts a question in the episode chat
    Given an active student named "Dana"
    And a published course "React Basics" with details "Learn React"
    And the course "React Basics" has a movie episode "Intro" at position 1
    And I am signed in as "Dana"
    When I open the episode "Intro" in "React Basics"
    And I post the chat message "What is a component?"
    Then the chat thread contains "What is a component?"
