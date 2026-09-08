require "json"
require "net/http"
require "securerandom"
require "uri"

class SessionsController < ApplicationController
  GOOGLE_AUTHORIZATION_ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth"
  GOOGLE_TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token"
  GOOGLE_USERINFO_ENDPOINT = "https://www.googleapis.com/oauth2/v3/userinfo"

  skip_before_action :authenticate_user!, only: [:new, :google_start, :create, :failure]
  skip_before_action :require_admin!, only: [:new, :google_start, :create, :failure]

  def new
  end

  def google_start
    unless google_credentials_configured?
      return redirect_to login_path, alert: I18n.t("login.google_not_configured")
    end

    session[:google_oauth_state] = SecureRandom.urlsafe_base64(32)
    redirect_to google_authorization_uri, allow_other_host: true
  end

  def create
    user_attributes = authenticated_user_attributes

    unless user_attributes
      return redirect_to login_path, alert: I18n.t("login.failed")
    end

    user = AuthenticatedUser.new(user_attributes)
    return redirect_to login_path, alert: I18n.t("login.stopped") if user.stopped?

    reset_session
    session[:authenticated_user] = user_attributes
    session[:locale] = user.locale
    redirect_to root_path, notice: I18n.t("login.signed_in")
  end

  def destroy
    reset_session
    redirect_to login_path, notice: I18n.t("login.signed_out")
  end

  def failure
    redirect_to login_path, alert: I18n.t("login.failed")
  end

  private

  def authenticated_user_attributes
    auth = request.env["omniauth.auth"]
    auth ||= Rails.application.env_config["omniauth.auth"] if Rails.env.test?
    return google_userinfo_attributes unless auth

    raw_info = auth.dig("extra", "raw_info") || {}
    email = auth.dig("info", "email").to_s.downcase
    return if email.blank?

    {
      "email" => email,
      "display_name" => auth.dig("info", "name").presence || email,
      "locale" => normalized_locale(raw_info["locale"]),
      "picture_url" => auth.dig("info", "image").to_s
    }
  end

  def google_userinfo_attributes
    return unless params[:provider] == "google_oauth2"
    return unless google_credentials_configured?
    return unless params[:code].present?
    return unless valid_google_state?

    access_token = exchange_google_code(params[:code])
    return unless access_token

    fetch_google_userinfo(access_token)
  end

  def google_credentials_configured?
    ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
  end

  def google_authorization_uri
    uri = URI(GOOGLE_AUTHORIZATION_ENDPOINT)
    uri.query = URI.encode_www_form(
      client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
      redirect_uri: google_callback_url,
      response_type: "code",
      scope: "email profile",
      state: session[:google_oauth_state],
      prompt: "select_account"
    )
    uri.to_s
  end

  def google_callback_url
    auth_callback_url(provider: "google_oauth2")
  end

  def valid_google_state?
    expected = session.delete(:google_oauth_state).to_s
    actual = params[:state].to_s
    expected.present? &&
      actual.bytesize == expected.bytesize &&
      ActiveSupport::SecurityUtils.secure_compare(actual, expected)
  end

  def exchange_google_code(code)
    response = Net::HTTP.post_form(
      URI(GOOGLE_TOKEN_ENDPOINT),
      "client_id" => ENV.fetch("GOOGLE_CLIENT_ID"),
      "client_secret" => ENV.fetch("GOOGLE_CLIENT_SECRET"),
      "code" => code,
      "grant_type" => "authorization_code",
      "redirect_uri" => google_callback_url
    )
    return unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)["access_token"].presence
  rescue JSON::ParserError, StandardError => e
    Rails.logger.warn("Google OAuth token exchange failed: #{e.class}")
    nil
  end

  def fetch_google_userinfo(access_token)
    uri = URI(GOOGLE_USERINFO_ENDPOINT)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    return unless response.is_a?(Net::HTTPSuccess)

    info = JSON.parse(response.body)
    email = info["email"].to_s.downcase
    return if email.blank? || info["email_verified"] == false

    {
      "email" => email,
      "display_name" => info["name"].presence || email,
      "locale" => normalized_locale(info["locale"]),
      "picture_url" => info["picture"].to_s
    }
  rescue JSON::ParserError, StandardError => e
    Rails.logger.warn("Google OAuth userinfo fetch failed: #{e.class}")
    nil
  end

  def normalized_locale(locale)
    candidate = locale.to_s.split(/[-_]/).first
    return candidate if I18n.available_locales.map(&:to_s).include?(candidate)

    I18n.default_locale.to_s
  end
end
