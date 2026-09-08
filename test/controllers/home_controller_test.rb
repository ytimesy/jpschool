require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "next lesson title description minutes and link come from one lesson" do
    get root_url

    assert_response :success
    assert_select ".focus-card h3", text: "遅刻・欠勤・体調"
    assert_select ".focus-card p", text: /遅刻、欠勤、けが、体調不良/
    assert_select ".focus-card span", text: "7分"
    assert_select ".focus-card a[href='#{lesson_path(3)}']", text: I18n.t("home.start_resume")
    assert_no_match "時間と勤務", response.body
  end
end
