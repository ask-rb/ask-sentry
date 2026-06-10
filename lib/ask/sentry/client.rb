# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "ask/auth"

module Ask
  module Sentry
    # Returns an authenticated Faraday client configured for the Sentry REST API.
    #
    # Resolves the Sentry token via +Ask::Auth.resolve(:sentry_token)+ and
    # configures the client with sensible defaults:
    #
    # - +base URL+: +https://sentry.io/api/0/+
    # - +Authorization+: Bearer token
    # - +middleware+: Faraday retry middleware (3 retries, exponential backoff)
    #
    # The client is wrapped in a +ClientProxy+ that converts
    # HTTP 401 responses into +Ask::Auth::InvalidCredential+.
    #
    # @example
    #   client = Ask::Sentry.client
    #   issues = client.get("projects/myorg/myapp/issues/")
    #
    # @return [ClientProxy] an authenticated HTTP client
    # @raise [Ask::Auth::MissingCredential] if no Sentry token is configured
    # @raise [Ask::Auth::InvalidCredential] if the token is rejected (401)
    def self.client
      token = Ask::Auth.resolve(:sentry_token)

      client = Faraday.new(url: "https://sentry.io/api/0/") do |f|
        f.request :authorization, :Bearer, token
        f.headers["Content-Type"] = "application/json"
        f.request :retry, max: 3, interval: 1, backoff_factor: 2,
                          retry_statuses: [429, 500, 502, 503]
        f.adapter Faraday.default_adapter
      end

      ClientProxy.new(client)
    end

    # Convenience wrapper to fetch recent errors for a given organization and project.
    #
    # @param organization [String] Sentry organization slug
    # @param project [String] Sentry project slug
    # @param limit [Integer] Maximum number of issues to return (default: 10)
    # @return [Faraday::Response] API response
    def self.recent_errors(organization:, project:, limit: 10)
      client.get("projects/#{organization}/#{project}/issues/") do |req|
        req.params[:limit] = limit
      end
    end

    # Convenience wrapper to fetch events for a specific issue.
    #
    # @param issue_id [Integer, String] Sentry issue ID
    # @param limit [Integer] Maximum number of events to return (default: 10)
    # @return [Faraday::Response] API response
    def self.issue_events(issue_id, limit: 10)
      client.get("issues/#{issue_id}/events/") do |req|
        req.params[:limit] = limit
      end
    end

    # Proxies method calls to a +Faraday::Connection+, converting 401 responses
    # into +Ask::Auth::InvalidCredential+.
    class ClientProxy < BasicObject
      def initialize(client)
        @client = client
      end

      def method_missing(name, ...)
        response = @client.public_send(name, ...)

        if response.is_a?(::Faraday::Response) && response.status == 401
          ::Kernel.raise ::Ask::Auth::InvalidCredential, :sentry_token
        end

        response
      end

      def respond_to_missing?(name, include_private = false)
        @client.respond_to?(name, include_private) || super
      end
    end
  end
end
