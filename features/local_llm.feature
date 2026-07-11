Feature: Local LLM client
  AI runs against a local, self-hosted model when one is configured
  (Ai::LocalClient), so proprietary code never leaves Comtec. When nothing is
  configured it falls back to a safe stub.

  Scenario: Route AI requests to the local model when configured
    Given a fake local LLM that replies "מודל מקומי ענה כאן"
    And the local LLM endpoint is configured to that server
    When the assistant answers a question about an episode
    Then the request was sent to the local endpoint
    And the reply is "מודל מקומי ענה כאן"

  Scenario: Fall back to the stub when the local LLM is not configured
    Given the local LLM is not configured
    When the assistant answers a question about an episode
    Then a non-empty reply is returned
