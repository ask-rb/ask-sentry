# frozen_string_literal: true

module Ask
  module Sentry
    # Human-readable description of the Sentry service context.
    DESCRIPTION = "Sentry — error tracking via the Sentry API"

    # Base URL for Sentry REST API documentation.
    DOCS_URL = "https://docs.sentry.io/api/"

    # URL for the Sentry OpenAPI specification.
    OPENAPI_URL = "https://sentry.io/api/0/"

    # Credential name used with Ask::Auth.resolve.
    AUTH_NAME = :sentry_token

    # Instructions for obtaining a Sentry auth token.
    AUTH_HOW = "https://sentry.io/settings/account/api/auth-tokens/"

    # Gem name for the HTTP client.
    GEM_NAME = "faraday"

    # Required gem version constraint.
    GEM_VERSION = "~> 2.0"

    # URL for Faraday library documentation.
    GEM_DOCS = "https://lostisland.github.io/faraday"

    # Quick-start Ruby code snippet for agents to copy-paste.
    QUICK_START = <<~RUBY
      client = Ask::Sentry.client
      issues = client.get("/api/0/projects/ORG/PROJECT/issues/", limit: 10)

      # Or use the helper:
      Ask::Sentry.recent_errors(organization: "myorg", project: "myapp", limit: 10)
    RUBY
  end
end
