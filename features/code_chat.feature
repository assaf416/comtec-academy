Feature: AI code-investigation chat
  Engineers open a snippet and ask questions; the local LLM answers grounded in
  the code, and the conversation is saved.

  Scenario: Ask about a C# snippet
    Given an active student named "Dana"
    And a snippet "Payroll calc" in "csharp" by "Dana"
    And a fake local LLM that replies "המתודה מחשבת שכר לעובד"
    And the local LLM endpoint is configured to that server
    And I am signed in as "Dana"
    When I open the snippet "Payroll calc"
    And I post the code chat message "what does this method do?"
    Then the code chat thread contains "what does this method do?"
    And the code chat thread contains "המתודה מחשבת שכר לעובד"

  Scenario: Conversation is persisted
    Given an active student named "Dana"
    And a snippet "Batch job" in "cobol" by "Dana"
    And I am signed in as "Dana"
    When I open the snippet "Batch job"
    And I post the code chat message "explain the paragraph"
    Then the snippet "Batch job" has a saved code chat conversation
