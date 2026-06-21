---
name: sentry.use_sentry
description: How to navigate the Sentry API — fetch issues, events, and error details
---

Use this skill when you need to interact with Sentry — reviewing error issues,
checking event details, or debugging production errors.

## Step 1: Get the Client

```ruby
client = Ask::Sentry.client
```

This returns an authenticated `Faraday::Connection` pointed at
`https://sentry.io/api/0/`. It expects a valid Sentry auth token resolved
via `Ask::Auth.resolve(:sentry_token)`.

## Step 2: Explore the Context

```ruby
Ask::Sentry::Context::DOCS_URL     # Sentry API docs
Ask::Sentry::Context::QUICK_START  # Copy-paste examples
```

The `QUICK_START` has examples for listing issues and events.

## Step 3: Use Convenience Helpers First

The gem ships with helpers for the most common operations:

```ruby
# Recent errors for a project
issues = Ask::Sentry.recent_errors(organization: "myorg", project: "myapp", limit: 10)

# Events for a specific issue
events = Ask::Sentry.issue_events(ISSUE_ID, limit: 10)
```

## Step 4: Raw API Calls

For endpoints without convenience helpers:

```ruby
client = Ask::Sentry.client

# List projects
client.get("projects/")

# List issues for a project
client.get("projects/ORG/PROJECT/issues/", limit: 20, query: "is:unresolved")

# Get event details
client.get("issues/ISSUE_ID/events/latest/")

# List releases
client.get("projects/ORG/PROJECT/releases/")
```

Sentry's API uses path parameters — the base URL already includes `/api/0/`.

## Step 5: Authentication & Common Errors

```ruby
Ask::Sentry::Errors.status_code_description(401)
Ask::Sentry::Errors.status_code_description(429)
```

Common scenarios:
- **401**: Token invalid or revoked → regenerate at Sentry auth token settings
- **403**: Token lacks scope → check token permissions
- **404**: Wrong org/project slug → verify slugs in Sentry dashboard
- **429**: Rate limited → wait and retry (Faraday auto-retries 3 times)

## Step 6: Fallback Strategy

1. Reference `Ask::Sentry::Context::DOCS_URL` for the full API reference
2. Sentry's API is REST + JSON — standard GET requests with URL path parameters
3. Organization and project slugs are required for most endpoints — get them
   from the Sentry dashboard URL (`/organizations/{ORG}/projects/{PROJECT}/`)
