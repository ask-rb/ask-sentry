# frozen_string_literal: true

require_relative "test_helper"

class ContextTest < Minitest::Test
  def test_description_is_defined
    assert_match(/Sentry/, Ask::Sentry::DESCRIPTION)
  end

  def test_docs_url_is_defined
    assert Ask::Sentry::DOCS_URL.start_with?("https://docs.sentry.io")
  end

  def test_openapi_url_is_defined
    assert Ask::Sentry::OPENAPI_URL.start_with?("https://sentry.io")
  end

  def test_auth_name_is_sentry_token
    assert_equal :sentry_token, Ask::Sentry::AUTH_NAME
  end

  def test_auth_how_is_defined
    assert_includes Ask::Sentry::AUTH_HOW, "settings/account/api/auth-tokens"
  end

  def test_gem_name_is_faraday
    assert_equal "faraday", Ask::Sentry::GEM_NAME
  end

  def test_gem_version_is_defined
    assert_match(/~> 2\.0/, Ask::Sentry::GEM_VERSION)
  end

  def test_gem_docs_is_defined
    assert Ask::Sentry::GEM_DOCS.start_with?("https://lostisland.github.io")
  end

  def test_quick_start_is_defined
    assert_includes Ask::Sentry::QUICK_START, "Ask::Sentry.client"
  end

  def test_quick_start_includes_common_methods
    %w[recent_errors].each do |method|
      assert_includes Ask::Sentry::QUICK_START, method
    end
  end
end
