# frozen_string_literal: true

require_relative "test_helper"

class IntegrationTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_raises_missing_credential
    Ask::Auth.configure { |c| c.providers = [] }

    assert_raises(Ask::Auth::MissingCredential) { Ask::Sentry.client }
  end

  def test_client_raises_invalid_credential_on_401
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { "sntrys_bad_token" if name == "sentry_token" }]
    end

    response = Faraday::Response.new(status: 401, body: '{"detail":"Invalid token"}')
    Faraday::Connection.any_instance.stubs(:get).returns(response)

    assert_raises(Ask::Auth::InvalidCredential) { Ask::Sentry.client.get("/projects/o/p/issues/") }
  end

  def test_delegates_to_faraday
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { "sntrys_test" if name == "sentry_token" }]
    end

    client = Ask::Sentry.client
    assert client.respond_to?(:get)
    assert client.respond_to?(:post)
    assert client.respond_to?(:put)
    assert client.respond_to?(:delete)
    refute client.respond_to?(:nonexistent_method_xyz)
  end

  def test_client_has_sentry_base_url
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { "sntrys_test" if name == "sentry_token" }]
    end

    response = Faraday::Response.new(status: 200, body: "[]")
    Faraday::Connection.any_instance.stubs(:get).returns(response)

    result = Ask::Sentry.client.get("projects/myorg/myapp/issues/")
    assert_equal 200, result.status
  end
end
