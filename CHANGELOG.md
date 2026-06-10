# Changelog

## 0.1.0 (2026-06-10)

- Initial release
- `Ask::Sentry.client` — authenticated Faraday client for the Sentry REST API
- `Ask::Sentry.recent_errors` — convenience wrapper to fetch recent issues
- `Ask::Sentry.issue_events` — convenience wrapper to fetch issue events
- `Ask::Sentry::Errors` — structured error knowledge for common HTTP codes, rate limits, pagination
- Auth token resolution via `Ask::Auth.resolve(:sentry_token)`
- 401 response detection with `Ask::Auth::InvalidCredential` error
- Faraday retry middleware (3 retries, exponential backoff)
