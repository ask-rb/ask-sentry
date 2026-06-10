# frozen_string_literal: true

module Ask
  module Sentry
    # Structured error knowledge for AI agents working with the Sentry API.
    #
    # Provides human-readable guidance for common HTTP status codes, rate
    # limiting, pagination, and authentication errors encountered when
    # using the Faraday-based Sentry client.
    module Errors
      # Rate limit information.
      #
      # - Sentry rate limits are based on the plan (see Sentry docs).
      # - When rate-limited, the API returns 429 Too Many Requests.
      # - The agent should wait for the Retry-After header and retry.
      RATE_LIMIT = {
        description: "Sentry rate limits vary by plan. See https://docs.sentry.io/api/rate-limiting/",
        error_status: 429,
        action: "Wait for the Retry-After header duration, then retry the request."
      }.freeze

      # Common HTTP status codes returned by the Sentry API and how to handle them.
      STATUS_CODES = {
        200 => "OK — Request succeeded.",
        201 => "Created — Resource was created successfully.",
        202 => "Accepted — Request accepted for processing.",
        204 => "No Content — Request succeeded, no response body.",
        400 => "Bad Request — Invalid request parameters. Check the request body.",
        401 => "Unauthorized — Auth token is missing, invalid, or revoked. Re-authenticate.",
        403 => "Forbidden — Token lacks the required scopes for this resource.",
        404 => "Not Found — The requested resource does not exist.",
        409 => "Conflict — Resource state conflict.",
        413 => "Payload Too Large — Request body exceeds the maximum size limit.",
        429 => "Too Many Requests — Rate limit exceeded. Wait before retrying.",
        500 => "Internal Server Error — Sentry server issue. Retry with backoff.",
        502 => "Bad Gateway — Sentry upstream issue. Retry with backoff.",
        503 => "Service Unavailable — Sentry is temporarily unavailable. Retry later."
      }.freeze

      # Pagination guidance for large result sets.
      PAGINATION = {
        link_header: "Sentry uses Link headers for pagination. The Faraday client receives these in the response headers.",
        cursor_based: "Sentry uses cursor-based pagination via the 'Link' header with 'rel=\"next\"' and 'rel=\"previous\"'.",
        per_page: "Use the 'limit' query parameter to control page size.",
        max_results: "For large queries, paginate using cursor values from the Link header."
      }.freeze

      # Map of error scenarios to human-readable guidance.
      EXCEPTIONS = {
        "Faraday::UnauthorizedError" => {
          message: "Your Sentry auth token is invalid or has been revoked.",
          action: "Generate a new token at https://sentry.io/settings/account/api/auth-tokens/ with the necessary scopes."
        },
        "Faraday::ForbiddenError" => {
          message: "Your token lacks the required permissions for this operation.",
          action: "Check your token scopes at https://sentry.io/settings/account/api/auth-tokens/."
        },
        "Faraday::ResourceNotFound" => {
          message: "The requested project, issue, or resource does not exist.",
          action: "Verify the organization slug, project slug, and resource identifiers."
        },
        "Faraday::TimeoutError" => {
          message: "The request to Sentry timed out.",
          action: "Check Sentry service status at https://status.sentry.io/ and retry the request."
        },
        "Faraday::TooManyRequestsError" => {
          message: "Sentry API rate limit exceeded.",
          action: "Check the Retry-After response header, wait the specified duration, then retry."
        },
        "Faraday::ClientError" => {
          message: "Sentry API returned a client error (4xx).",
          action: "Check the request parameters, auth token, and resource identifiers."
        },
        "Faraday::ServerError" => {
          message: "Sentry API returned a server error (5xx).",
          action: "Retry with exponential backoff. If the issue persists, check https://status.sentry.io."
        }
      }.freeze

      # Look up guidance for an exception class name.
      #
      # @param exception_class [String] The exception class name (e.g., "Faraday::ResourceNotFound")
      # @return [Hash, nil] A hash with +:message+ and +:action+ keys, or nil if unknown
      def self.for(exception_class)
        EXCEPTIONS[exception_class]
      end

      # Describe an HTTP status code.
      #
      # @param code [Integer] HTTP status code
      # @return [String, nil] Description of the status code
      def self.status_code_description(code)
        STATUS_CODES[code]
      end
    end
  end
end
