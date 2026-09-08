require "test_helper"

class SelfAssessmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_with_google(email: "learner@example.com", name: "Current Learner")
  end

  test "saves self assessment for the selected lesson" do
    patch lesson_self_assessment_url(2), params: {
      authenticity_token: authenticity_token(lesson_id: 2),
      rating: 2
    }

    assert_redirected_to lesson_url(2)
    follow_redirect!
    assert_response :success
    assert_match "現在の自己評価", response.body
    assert_match "少し助けがあればできる", response.body
  end

  test "updates an existing self assessment" do
    patch lesson_self_assessment_url(2), params: {
      authenticity_token: authenticity_token(lesson_id: 2),
      rating: 2
    }
    patch lesson_self_assessment_url(2), params: {
      authenticity_token: authenticity_token(lesson_id: 2),
      rating: 1
    }

    assert_redirected_to lesson_url(2)
    follow_redirect!
    assert_select ".saved-assessment", text: /一人でできる/
    assert_select ".saved-assessment", text: /少し助けがあればできる/, count: 0
  end

  test "rejects missing self assessment rating" do
    patch lesson_self_assessment_url(2), params: {
      authenticity_token: authenticity_token(lesson_id: 2)
    }

    assert_redirected_to lesson_url(2)
    follow_redirect!
    assert_match "自己評価を選んでください。", response.body
  end

  test "evaluation shows saved self assessment" do
    patch lesson_self_assessment_url(3), params: {
      authenticity_token: authenticity_token(lesson_id: 3),
      rating: 3
    }
    get evaluation_url

    assert_response :success
    assert_match "かなり助けが必要", response.body
  end

  test "self assessment session is cleared when another Google user signs in" do
    patch lesson_self_assessment_url(2), params: {
      authenticity_token: authenticity_token(lesson_id: 2),
      rating: 4
    }
    follow_redirect!
    assert_select ".saved-assessment", text: /まだ難しい/

    delete logout_url, params: { authenticity_token: logout_authenticity_token }
    sign_in_with_google(email: "other@example.com", name: "Other Learner")
    get lesson_url(2)

    assert_response :success
    assert_select ".saved-assessment", count: 0
  end

  private

  def authenticity_token(lesson_id:)
    get lesson_url(lesson_id)
    assert_response :success

    response.body.match(/name="authenticity_token"[^>]*value="([^"]+)"/)[1]
  end

  def logout_authenticity_token
    get settings_url
    assert_response :success

    response.body.match(/name="authenticity_token"[^>]*value="([^"]+)"/)[1]
  end

end
