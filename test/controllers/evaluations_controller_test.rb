require "test_helper"

class EvaluationsControllerTest < ActionDispatch::IntegrationTest
  test "shows evaluation summary and lesson rows" do
    get evaluation_url

    assert_response :success
    assert_select "h2", text: "評価"
    assert_select ".evaluation-summary article", count: 4
    assert_select "tbody tr", count: 12
    assert_select "a[href='#{evaluation_certificate_path(format: :pdf)}']", text: "スキル証書PDF"
    assert_select "a[href='#{progress_path}']", count: 0
    assert_match "Web学習だけで日本語能力レベルを認定するものではありません", response.body
  end

  test "shows saved self assessment in evaluation" do
    patch lesson_self_assessment_url(2), params: {
      authenticity_token: authenticity_token(lesson_id: 2),
      rating: 2
    }

    get evaluation_url

    assert_response :success
    assert_match "少し助けがあればできる", response.body
  end

  test "downloads skill certificate pdf" do
    get evaluation_certificate_url(format: :pdf)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF-1.4")
    assert_includes response.body, "/UniJIS-UCS2-H"
    assert_includes response.body, "/HeiseiKakuGo-W5"
    assert_includes response.headers["Content-Disposition"], "work-nihongo-skill-certificate.pdf"
  end

  private

  def authenticity_token(lesson_id:)
    get lesson_url(lesson_id)
    assert_response :success

    response.body.match(/name="authenticity_token"[^>]*value="([^"]+)"/)[1]
  end
end
