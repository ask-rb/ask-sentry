# ask-sentry

[![Gem Version](https://badge.fury.io/rb/ask-sentry.svg)](https://badge.fury.io/rb/ask-sentry)

Sentry service context for AI agents in the ask-rb ecosystem. It provides an
authenticated HTTP client for the Sentry REST API, metadata constants for
system prompts, and a structured error guide for common Sentry API issues.

## Installation

```ruby
gem "ask-sentry"
```

## Quick Start

```ruby
require "ask-sentry"

# Recent issues for an organization and project
issues = Ask::Sentry.recent_errors(organization: "myorg", project: "myapp", limit: 10)

# Events for a specific issue
events = Ask::Sentry.issue_events(12345, limit: 10)

# Or use the raw client (base URL: https://sentry.io/api/0/)
client = Ask::Sentry.client
client.get("projects/myorg/myapp/issues/")
```

## Authentication

`Ask::Sentry.client` resolves a token via `Ask::Auth.resolve(:sentry_token)`.
Set it in your environment:

```bash
export SENTRY_TOKEN=your_token_here
```

Or add it to `~/.ask/credentials.yml`:

```yaml
sentry_token: your_token_here
```

Credentials can also come from Rails credentials, a database, or an OAuth
provider, depending on your `ask-auth` configuration. The token is sent as a
Bearer token. Create one at
[sentry.io/settings/account/api/auth-tokens](https://sentry.io/settings/account/api/auth-tokens/).

## Key entry points

- `Ask::Sentry.client` - an authenticated Faraday client with base URL
  `https://sentry.io/api/0/`. It is wrapped in a proxy that converts HTTP 401
  responses into `Ask::Auth::InvalidCredential`.
- `Ask::Sentry.recent_errors(organization:, project:, limit: 10)` - fetch
  recent issues for a project.
- `Ask::Sentry.issue_events(issue_id, limit: 10)` - fetch events for an issue.
- `Ask::Sentry::Errors` - structured error knowledge for agents: guidance by
  exception class, HTTP status descriptions, and rate limit info.
- `Ask::Sentry::DESCRIPTION`, `DOCS_URL`, `AUTH_NAME`, `GEM_NAME`, and
  `QUICK_START` - metadata constants for system prompts.

## Full documentation

The full ask-rb documentation lives at https://ask-rb.github.io/ask-docs.
[Services: Sentry](https://ask-rb.github.io/ask-docs/services/sentry) covers
ask-sentry in depth, including the client, error guide, and constants.
API reference: https://ask-rb.github.io/ask-docs/reference/api.

## Development

```
bundle install
bundle exec rake test
```

## License

MIT
