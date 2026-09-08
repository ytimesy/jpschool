require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login page is public and does not show learner navigation" do
    get login_url

    assert_response :success
    assert_select "h2", text: "しごと日本語へログイン"
    assert_select "button", text: "Googleアカウントでログイン"
    assert_select ".bottom-nav", count: 0
    assert_select "input[type=password]", count: 0
  end

  test "Google user can log in and access protected home" do
    mock_google_auth(email: "active@example.com", name: "Active User")
    get "/auth/google_oauth2/callback"

    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
    assert_match "Active User", response.body
  end

  test "Google login start redirects to Google when configured" do
    with_env("GOOGLE_CLIENT_ID" => "client-id", "GOOGLE_CLIENT_SECRET" => "client-secret") do
      post google_login_url, params: { authenticity_token: login_authenticity_token }
    end

    assert_response :redirect
    assert_match %r{\Ahttps://accounts\.google\.com/o/oauth2/v2/auth}, response.location
    assert_includes response.location, "client_id=client-id"
    assert_includes response.location, "scope=email+profile"
  end

  test "Google login start returns to login when credentials are missing" do
    with_env("GOOGLE_CLIENT_ID" => nil, "GOOGLE_CLIENT_SECRET" => nil) do
      post google_login_url, params: { authenticity_token: login_authenticity_token }
    end

    assert_redirected_to login_url
    follow_redirect!
    assert_response :success
    assert_match "Googleログイン設定が未完了です。", response.body
  end

  test "Google auth failure is rejected" do
    get "/auth/google_oauth2/callback"

    assert_redirected_to login_url
  end

  test "stopped Google account cannot log in" do
    with_env("GOOGLE_STOPPED_EMAILS" => "stopped@example.com") do
      mock_google_auth(email: "stopped@example.com", name: "Stopped User")
      get "/auth/google_oauth2/callback"
    end

    assert_redirected_to login_url
    follow_redirect!
    assert_response :success
    get root_url
    assert_redirected_to login_url
  end

  test "logout clears the session and protected pages require login again" do
    sign_in_with_google(email: "logout@example.com", name: "Logout User")

    delete logout_url, params: { authenticity_token: logout_authenticity_token }

    assert_redirected_to login_url
    get root_url
    assert_redirected_to login_url
  end

  test "learner cannot access admin area" do
    sign_in_with_google(email: "learner@example.com", name: "Learner User")

    get admin_root_url

    assert_redirected_to root_url
  end

  test "admin can access admin area" do
    with_env("GOOGLE_ADMIN_EMAILS" => "admin@example.com") do
      sign_in_with_google(email: "admin@example.com", name: "Admin User")
      get admin_root_url
    end

    assert_response :success
  end

  test "protected pages use no-store cache control" do
    sign_in_with_google(email: "cache@example.com", name: "Cache User")

    get root_url

    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_includes response.headers["Cache-Control"], "private"
  end

  test "protected learner and admin urls require login" do
    [
      root_url,
      lessons_url,
      lesson_url(1),
      lesson_quiz_url(1),
      review_url,
      evaluation_url,
      settings_url,
      admin_root_url
    ].each do |url|
      get url
      assert_redirected_to login_url
    end
  end

  test "public policy pages do not require login" do
    [login_url, basic_policy_url, terms_url, company_url].each do |url|
      get url
      assert_response :success
    end
  end

  test "initial setup is public and does not show password fields" do
    get initial_setup_url

    assert_response :success
    assert_select "input[type=password]", count: 0
    assert_match "確認してログインへ", response.body
  end

  private

  def login_authenticity_token
    get login_url
    assert_response :success

    response.body.match(/name="authenticity_token"[^>]*value="([^"]+)"/)[1]
  end

  def logout_authenticity_token
    get settings_url
    assert_response :success

    response.body.match(/name="authenticity_token"[^>]*value="([^"]+)"/)[1]
  end
end
