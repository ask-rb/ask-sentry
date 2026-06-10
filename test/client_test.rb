# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_returns_faraday_connection_when_token_available
    token = "sntrys_test_token_12345"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "sentry_token" }]
    end

    client = Ask::Sentry.client
    assert_kind_of Faraday::Connection, client
  end

  def test_client_uses_sentry_base_url
    token = "sntrys_test_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "sentry_token" }]
    end

    Faraday::Connection.any_instance.stubs(:get).returns(
      Faraday::Response.new(status: 200, body: "[]")
    )

    client = Ask::Sentry.client
    response = client.get("projects/myorg/myapp/issues/")
    assert_equal 200, response.status
  end

  def test_client_raises_missing_credential_without_token
    Ask::Auth.configure do |config|
      config.providers = []
    end

    assert_raises(Ask::Auth::MissingCredential) { Ask::Sentry.client }
  end

  def test_client_raises_invalid_credential_on_401
    token = "bad_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "sentry_token" }]
    end

    response = Faraday::Response.new(status: 401, body: '{"detail":"Invalid token"}')
    Faraday::Connection.any_instance.stubs(:get).returns(response)

    assert_raises(Ask::Auth::InvalidCredential) { Ask::Sentry.client.get("projects/o/p/issues/") }
  end

  def test_recent_errors_returns_response
    token = "sntrys_valid_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "sentry_token" }]
    end

    response = Faraday::Response.new(status: 200, body: '[{"id":"1","title":"Error"}]')
    Faraday::Connection.any_instance.stubs(:get).returns(response)

    result = Ask::Sentry.recent_errors(organization: "myorg", project: "myapp", limit: 5)
    assert_equal 200, result.status
  end

  def test_issue_events_returns_response
    token = "sntrys_valid_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "sentry_token" }]
    end

    response = Faraday::Response.new(status: 200, body: '[{"id":"1"}]')
    Faraday::Connection.any_instance.stubs(:get).returns(response)

    result = Ask::Sentry.issue_events(12345, limit: 10)
    assert_equal 200, result.status
  end

  def test_client_passes_through_successful_response
    token = "sntrys_valid_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "sentry_token" }]
    end

    response = Faraday::Response.new(status: 200, body: '{"id":"test"}')
    Faraday::Connection.any_instance.stubs(:get).returns(response)

    client = Ask::Sentry.client
    assert_equal response, client.get("issues/1/")
  end

  def test_client_allows_other_http_methods
    token = "sntrys_valid_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "sentry_token" }]
    end

    response = Faraday::Response.new(status: 200, body: "{}")
    Faraday::Connection.any_instance.stubs(:post).returns(response)

    client = Ask::Sentry.client
    assert_equal response, client.post("issues/1/hash/", {}.to_json)
  end
end
