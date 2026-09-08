ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: 1)

  setup do
    Rails.application.env_config.delete("omniauth.auth")
  end

  def with_env(values)
    previous = values.transform_values { |_, _| nil }
    values.each_key { |key| previous[key] = ENV.fetch(key, nil) }
    values.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    previous&.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end
end

class ActionDispatch::IntegrationTest
  def sign_in_with_google(email: "learner@example.com", name: "Test User", locale: "ja")
    mock_google_auth(email:, name:, locale:)
    get "/auth/google_oauth2/callback"
    assert_redirected_to root_url
  end

  def mock_google_auth(email: "learner@example.com", name: "Test User", locale: "ja")
    Rails.application.env_config["omniauth.auth"] = {
      "provider" => "google_oauth2",
      "uid" => email,
      "info" => {
        "email" => email,
        "name" => name,
        "image" => "https://example.com/avatar.png"
      },
      "extra" => {
        "raw_info" => {
          "locale" => locale
        }
      }
    }
  end
end
