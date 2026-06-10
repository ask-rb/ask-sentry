# frozen_string_literal: true

require_relative "test_helper"

class ErrorGuideTest < Minitest::Test
  def test_rate_limit_is_defined
    assert Ask::Sentry::Errors::RATE_LIMIT.key?(:description)
    assert Ask::Sentry::Errors::RATE_LIMIT.key?(:error_status)
    assert Ask::Sentry::Errors::RATE_LIMIT.key?(:action)
  end

  def test_rate_limit_has_429_status
    assert_equal 429, Ask::Sentry::Errors::RATE_LIMIT[:error_status]
  end

  def test_status_codes_cover_common_codes
    [200, 201, 204, 400, 401, 403, 404, 409, 429, 500, 502, 503].each do |code|
      assert Ask::Sentry::Errors::STATUS_CODES.key?(code), "Missing status code #{code}"
    end
  end

  def test_status_code_description_returns_string
    desc = Ask::Sentry::Errors.status_code_description(404)
    assert_match(/Not Found/, desc)
  end

  def test_status_code_description_returns_nil_for_unknown
    assert_nil Ask::Sentry::Errors.status_code_description(999)
  end

  def test_exceptions_cover_common_errors
    %w[
      Faraday::UnauthorizedError
      Faraday::ForbiddenError
      Faraday::ResourceNotFound
      Faraday::TimeoutError
      Faraday::TooManyRequestsError
      Faraday::ClientError
      Faraday::ServerError
    ].each do |klass|
      assert Ask::Sentry::Errors::EXCEPTIONS.key?(klass), "Missing exception #{klass}"
    end
  end

  def test_for_returns_guidance
    guidance = Ask::Sentry::Errors.for("Faraday::ResourceNotFound")
    assert guidance.key?(:message)
    assert guidance.key?(:action)
  end

  def test_for_returns_nil_for_unknown
    assert_nil Ask::Sentry::Errors.for("Some::Unknown::Error")
  end

  def test_exception_messages_are_helpful
    error = Ask::Sentry::Errors.for("Faraday::UnauthorizedError")
    assert_includes error[:action], "sentry.io/settings/account/api/auth-tokens"
  end

  def test_pagination_info_is_defined
    assert Ask::Sentry::Errors::PAGINATION.key?(:link_header)
    assert Ask::Sentry::Errors::PAGINATION.key?(:cursor_based)
    assert Ask::Sentry::Errors::PAGINATION.key?(:per_page)
  end
end
